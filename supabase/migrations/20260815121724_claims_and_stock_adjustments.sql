-- ============================================================
-- claims + stock_adjustments, and the stock ledger trigger
-- ============================================================

create table public.claims (
  id uuid primary key default gen_random_uuid(),

  product_id uuid not null
    references public.products(id) on delete restrict,

  quantity integer not null check (quantity > 0),

  -- Snapshots taken when the claim is raised, so later edits to the
  -- product never rewrite claim history.
  product_name_snapshot text not null,
  brand_name_snapshot text,
  customer_name_snapshot text
    check (customer_name_snapshot is null or char_length(customer_name_snapshot) <= 120),

  -- "Batch / Supplier Reference" in the Add Claim dialog. Free text:
  -- a supplier bill (BILL-2026-0143) or a carton ref (CTN-10).
  -- Deliberately NOT an SGX invoice number.
  batch_reference_snapshot text
    check (batch_reference_snapshot is null or char_length(batch_reference_snapshot) <= 40),

  -- Whether raising the claim pulls the units out of sellable stock.
  stock_effect text not null default 'remove_from_stock'
    check (stock_effect in ('remove_from_stock', 'no_stock_change')),

  claim_note text check (claim_note is null or char_length(claim_note) <= 500),

  status text not null default 'pending'
    check (status in ('pending', 'sent_to_supplier', 'settled', 'written_off')),

  -- Supplier handover
  supplier_name text check (supplier_name is null or char_length(supplier_name) <= 100),
  sent_to_supplier_at timestamptz,
  sent_quantity integer check (sent_quantity is null or sent_quantity > 0),
  sent_note text check (sent_note is null or char_length(sent_note) <= 500),

  -- Settlement
  settlement_type text
    check (settlement_type is null or settlement_type in
      ('cash_refund', 'replacement_stock', 'credit_note', 'other')),
  settlement_amount numeric(10, 2)
    check (settlement_amount is null or (settlement_amount >= 0 and settlement_amount <= 9999999.99)),
  settled_at timestamptz,
  settled_note text check (settled_note is null or char_length(settled_note) <= 500),

  -- Write-off
  write_off_reason text
    check (write_off_reason is null or write_off_reason in
      ('supplier_rejected', 'beyond_warranty', 'customer_fault', 'other')),
  written_off_at timestamptz,
  write_off_note text check (write_off_note is null or char_length(write_off_note) <= 500),

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid references public.profiles(id) on delete set null,
  updated_by uuid references public.profiles(id) on delete set null,

  -- A partial send can never exceed what was claimed.
  constraint claims_sent_quantity_within_claim
    check (sent_quantity is null or sent_quantity <= quantity)
);

create index claims_status_idx on public.claims (status);
create index claims_product_idx on public.claims (product_id);
create index claims_created_at_idx on public.claims (created_at desc);
create index claims_created_by_idx on public.claims (created_by);
create index claims_updated_by_idx on public.claims (updated_by);

create trigger claims_updated_at
before update on public.claims
for each row execute function public.handle_updated_at();

-- ------------------------------------------------------------
-- stock_adjustments: the append-only ledger behind products.stock
-- ------------------------------------------------------------
create table public.stock_adjustments (
  id uuid primary key default gen_random_uuid(),

  product_id uuid not null
    references public.products(id) on delete restrict,

  source text not null
    check (source in (
      'add_stock',
      'stock_adjustment',
      'invoice_dispatch',
      'customer_return',
      'claim_submitted'
    )),

  type_detail text not null
    check (char_length(type_detail) between 2 and 100),

  -- Signed: positive adds stock, negative removes it. Never zero.
  quantity_change integer not null check (quantity_change <> 0),

  -- Filled by the trigger below, not by the application.
  stock_before integer not null check (stock_before >= 0),
  stock_after integer not null check (stock_after >= 0),

  invoice_id uuid, -- FK added with Module 09 Invoices
  claim_id uuid references public.claims(id) on delete set null,

  supplier_name text
    check (supplier_name is null or char_length(supplier_name) <= 100),
  supplier_reference text
    check (supplier_reference is null or char_length(supplier_reference) <= 50),

  note text check (note is null or char_length(note) <= 500),

  created_at timestamptz not null default now(),
  created_by uuid references public.profiles(id) on delete set null
);

create index stock_adjustments_product_idx on public.stock_adjustments (product_id);
create index stock_adjustments_source_idx on public.stock_adjustments (source);
create index stock_adjustments_created_at_idx on public.stock_adjustments (created_at desc);
create index stock_adjustments_claim_idx on public.stock_adjustments (claim_id);
create index stock_adjustments_created_by_idx on public.stock_adjustments (created_by);
create index stock_adjustments_invoice_idx on public.stock_adjustments (invoice_id);

-- ------------------------------------------------------------
-- Stock ledger. Inserting an adjustment is the ONLY way stock moves:
-- the trigger locks the product row, derives stock_before/stock_after
-- from live stock, and writes the new total back.
-- ------------------------------------------------------------
create or replace function public.apply_stock_adjustment()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
declare
  current_stock integer;
begin
  -- Row lock serializes concurrent adjustments to the same product.
  select p.stock into current_stock
  from public.products p
  where p.id = new.product_id
  for update;

  if current_stock is null then
    raise exception 'Product % not found', new.product_id
      using errcode = '23503';
  end if;

  new.stock_before := current_stock;
  new.stock_after := current_stock + new.quantity_change;

  if new.stock_after < 0 then
    raise exception 'Cannot reduce stock below zero. Available: %, requested change: %',
      current_stock, new.quantity_change
      using errcode = '23514';
  end if;

  -- Authorize this one write past the guard trigger below.
  perform set_config('sgx.stock_sync', 'on', true);

  update public.products
  set stock = new.stock_after
  where id = new.product_id;

  perform set_config('sgx.stock_sync', 'off', true);

  return new;
end;
$$;

create trigger stock_adjustments_apply
before insert on public.stock_adjustments
for each row execute function public.apply_stock_adjustment();

-- The ledger is append-only.
create or replace function public.block_stock_adjustment_mutation()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  raise exception 'stock_adjustments is append-only. Insert a compensating adjustment instead.'
    using errcode = '0A000';
end;
$$;

create trigger stock_adjustments_no_update
before update or delete on public.stock_adjustments
for each row execute function public.block_stock_adjustment_mutation();

-- products.stock may only change through the ledger.
create or replace function public.guard_product_stock()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if new.stock is distinct from old.stock
     and coalesce(current_setting('sgx.stock_sync', true), 'off') <> 'on' then
    raise exception 'products.stock is derived. Insert a stock_adjustments row instead of updating stock directly.'
      using errcode = '0A000';
  end if;
  return new;
end;
$$;

create trigger products_stock_guard
before update on public.products
for each row execute function public.guard_product_stock();

-- ------------------------------------------------------------
-- RLS: staff only for both tables.
-- ------------------------------------------------------------
alter table public.claims enable row level security;
alter table public.stock_adjustments enable row level security;

create policy claims_select_staff on public.claims
for select to authenticated
using ((select private.is_staff()));

create policy claims_write_staff on public.claims
for all to authenticated
using ((select private.is_staff()))
with check ((select private.is_staff()));

create policy stock_adjustments_select_staff on public.stock_adjustments
for select to authenticated
using ((select private.is_staff()));

create policy stock_adjustments_insert_staff on public.stock_adjustments
for insert to authenticated
with check ((select private.is_staff()));

grant select, insert, update, delete on public.claims to authenticated;
grant select, insert on public.stock_adjustments to authenticated;

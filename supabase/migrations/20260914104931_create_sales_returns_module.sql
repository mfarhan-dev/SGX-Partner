-- Module 18: Sales Returns
-- One RPC owns the complete counter workflow so a return can never be saved
-- without its corresponding stock, khata, claim, and audit effects.

create sequence public.sales_return_number_seq start with 1;

create table public.sales_returns (
  id uuid primary key default gen_random_uuid(),
  return_number text not null unique default ('SR-' || lpad(nextval('public.sales_return_number_seq')::text, 4, '0')),
  sale_type text not null check (sale_type in ('wholesaler', 'mechanic', 'customer')),
  is_cash_walk_in boolean not null default false,
  wholesaler_id uuid references public.wholesalers(id) on delete restrict,
  invoice_number text,
  settlement text not null check (settlement in ('khata_adjustment', 'cash_paid')),
  previous_khata numeric(12, 2) not null default 0,
  return_total numeric(12, 2) not null check (return_total > 0),
  cash_paid numeric(12, 2) not null default 0 check (cash_paid >= 0),
  new_khata numeric(12, 2) not null default 0,
  note text check (note is null or char_length(note) <= 500),
  idempotency_key uuid not null unique,
  created_at timestamptz not null default now(),
  created_by uuid references public.profiles(id) on delete set null,
  constraint sales_returns_party_consistency check (
    (is_cash_walk_in and wholesaler_id is null and settlement = 'cash_paid')
    or (not is_cash_walk_in and wholesaler_id is not null)
  )
);

create table public.sales_return_lines (
  id uuid primary key default gen_random_uuid(),
  sales_return_id uuid not null references public.sales_returns(id) on delete cascade,
  product_id uuid not null references public.products(id) on delete restrict,
  product_name_snapshot text not null,
  product_code_snapshot text not null,
  brand_snapshot text,
  resolution text not null check (resolution in ('refund', 'return', 'replacement_claim')),
  quantity integer not null check (quantity > 0),
  rate numeric(12, 2) not null check (rate > 0),
  total numeric(12, 2) not null check (total > 0),
  claim_id uuid references public.claims(id) on delete restrict,
  created_at timestamptz not null default now(),
  constraint sales_return_lines_claim_matches_resolution check (
    (resolution = 'replacement_claim' and claim_id is not null)
    or (resolution in ('refund', 'return') and claim_id is null)
  )
);

alter table public.stock_adjustments add column sales_return_id uuid references public.sales_returns(id) on delete restrict;
alter table public.khata_entries add constraint khata_entries_sales_return_id_fkey foreign key (sales_return_id) references public.sales_returns(id) on delete restrict;
alter table public.claims add column sales_return_id uuid references public.sales_returns(id) on delete restrict;

create index sales_returns_created_at_idx on public.sales_returns (created_at desc);
create index sales_returns_wholesaler_idx on public.sales_returns (wholesaler_id, created_at desc) where wholesaler_id is not null;
create index sales_return_lines_return_idx on public.sales_return_lines (sales_return_id);
create index sales_return_lines_product_idx on public.sales_return_lines (product_id);
create index stock_adjustments_sales_return_idx on public.stock_adjustments (sales_return_id) where sales_return_id is not null;
create index claims_sales_return_idx on public.claims (sales_return_id) where sales_return_id is not null;

alter table public.sales_returns enable row level security;
alter table public.sales_return_lines enable row level security;

create policy sales_returns_select_staff on public.sales_returns for select to authenticated using ((select private.is_staff()));
create policy sales_return_lines_select_staff on public.sales_return_lines for select to authenticated using ((select private.is_staff()));

grant select on public.sales_returns, public.sales_return_lines to authenticated;

create or replace function public.create_sales_return(
  p_sale_type text,
  p_wholesaler_id uuid,
  p_is_cash_walk_in boolean,
  p_invoice_number text,
  p_settlement text,
  p_note text,
  p_lines jsonb,
  p_idempotency_key uuid
) returns table (id uuid, return_number text)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_return public.sales_returns%rowtype;
  v_previous_khata numeric(12, 2) := 0;
  v_settlement_total numeric(12, 2) := 0;
  v_return_total numeric(12, 2) := 0;
  v_line record;
  v_product record;
  v_claim_id uuid;
  v_actor public.profiles%rowtype;
begin
  if not (select private.is_staff()) then raise exception 'Not authorized' using errcode = '42501'; end if;
  if p_sale_type not in ('wholesaler', 'mechanic', 'customer') then raise exception 'Please select a sale type' using errcode = '22023'; end if;
  if p_settlement not in ('khata_adjustment', 'cash_paid') then raise exception 'Invalid settlement' using errcode = '22023'; end if;
  if p_is_cash_walk_in and p_settlement <> 'cash_paid' then raise exception 'Cash returns must be paid in cash' using errcode = '22023'; end if;
  if not p_is_cash_walk_in and (p_sale_type <> 'wholesaler' or p_wholesaler_id is null) then raise exception 'Please select a wholesaler.' using errcode = '22023'; end if;
  if jsonb_typeof(p_lines) <> 'array' or jsonb_array_length(p_lines) = 0 then raise exception 'Add at least one returned product.' using errcode = '22023'; end if;

  select * into v_return from public.sales_returns where idempotency_key = p_idempotency_key;
  if found then return query select v_return.id, v_return.return_number; return; end if;

  if not p_is_cash_walk_in then
    select khata_balance into v_previous_khata from public.wholesalers where id = p_wholesaler_id and is_active for update;
    if not found then raise exception 'That wholesaler could not be found.' using errcode = '23503'; end if;
  end if;

  for v_line in select * from jsonb_to_recordset(p_lines) as x(product_id uuid, quantity integer, rate numeric, resolution text) loop
    if v_line.quantity is null or v_line.quantity < 1 then raise exception 'Quantity must be at least 1.' using errcode = '22023'; end if;
    if v_line.rate is null or v_line.rate <= 0 then raise exception 'Rate must be greater than 0.' using errcode = '22023'; end if;
    if v_line.resolution not in ('refund', 'return', 'replacement_claim') then raise exception 'Invalid customer resolution' using errcode = '22023'; end if;
    select p.id, p.name, p.buying_price, b.name as brand_name into v_product from public.products p join public.brands b on b.id = p.brand_id where p.id = v_line.product_id and p.deleted_at is null;
    if not found then raise exception 'One of the selected products could not be found. Please try again.' using errcode = '23503'; end if;
    if v_line.rate < v_product.buying_price then raise exception 'Rate cannot be less than the purchase price.' using errcode = '22023'; end if;
    v_return_total := v_return_total + (v_line.quantity * v_line.rate);
    if v_line.resolution <> 'replacement_claim' then v_settlement_total := v_settlement_total + (v_line.quantity * v_line.rate); end if;
  end loop;

  insert into public.sales_returns (sale_type, is_cash_walk_in, wholesaler_id, invoice_number, settlement, previous_khata, return_total, cash_paid, new_khata, note, idempotency_key, created_by)
  values (p_sale_type, p_is_cash_walk_in, case when p_is_cash_walk_in then null else p_wholesaler_id end, nullif(trim(p_invoice_number), ''), p_settlement, v_previous_khata, v_return_total, case when p_settlement = 'cash_paid' then v_settlement_total else 0 end, case when p_settlement = 'khata_adjustment' then v_previous_khata - v_settlement_total else v_previous_khata end, nullif(trim(p_note), ''), p_idempotency_key, auth.uid()) returning * into v_return;

  for v_line in select * from jsonb_to_recordset(p_lines) as x(product_id uuid, quantity integer, rate numeric, resolution text) loop
    select p.id, p.name, p.buying_price, b.name as brand_name into v_product from public.products p join public.brands b on b.id = p.brand_id where p.id = v_line.product_id and p.deleted_at is null;
    v_claim_id := null;
    if v_line.resolution = 'replacement_claim' then
      insert into public.claims (product_id, quantity, product_name_snapshot, brand_name_snapshot, customer_name_snapshot, batch_reference_snapshot, stock_effect, claim_note, sales_return_id, created_by, updated_by)
      values (v_product.id, v_line.quantity, v_product.name, v_product.brand_name, case when p_is_cash_walk_in then 'Cash Counter' else (select shop_name from public.wholesalers where id = p_wholesaler_id) end, v_return.return_number, 'no_stock_change', nullif(trim(p_note), ''), v_return.id, auth.uid(), auth.uid()) returning id into v_claim_id;
      insert into public.stock_adjustments (product_id, source, type_detail, quantity_change, claim_id, sales_return_id, supplier_reference, note, created_by)
      values (v_product.id, 'claim_submitted', 'Replacement Product Issued', -v_line.quantity, v_claim_id, v_return.id, v_return.return_number, nullif(trim(p_note), ''), auth.uid());
    else
      insert into public.stock_adjustments (product_id, source, type_detail, quantity_change, sales_return_id, supplier_reference, note, created_by)
      values (v_product.id, 'customer_return', case when v_line.resolution = 'refund' then 'Refunded Sales Return' else 'Sales Return / Exchange' end, v_line.quantity, v_return.id, v_return.return_number, nullif(trim(p_note), ''), auth.uid());
    end if;
    insert into public.sales_return_lines (sales_return_id, product_id, product_name_snapshot, product_code_snapshot, brand_snapshot, resolution, quantity, rate, total, claim_id)
    values (v_return.id, v_product.id, v_product.name, 'SGX-' || upper(replace(v_product.id::text, '-', '')), v_product.brand_name, v_line.resolution, v_line.quantity, v_line.rate, v_line.quantity * v_line.rate, v_claim_id);
  end loop;

  if p_settlement = 'khata_adjustment' and v_settlement_total > 0 then
    insert into public.khata_entries (wholesaler_id, entry_type, reference, note, credit, sales_return_id, created_by)
    values (p_wholesaler_id, 'sales_return', v_return.return_number, coalesce(nullif(trim(p_invoice_number), '') || ': ', '') || 'Sales return adjustment', v_settlement_total, v_return.id, auth.uid());
  end if;

  select * into v_actor from public.profiles where id = auth.uid();
  insert into public.audit_logs (actor_profile_id, actor_name, actor_role, module, action, target, summary, outcome, note, after_snapshot)
  values (auth.uid(), coalesce(v_actor.full_name, 'Staff'), v_actor.role, 'Sales Returns', 'Sales Return Created', v_return.return_number, coalesce(v_actor.full_name, 'Staff') || ' created ' || v_return.return_number || '.', 'success', nullif(trim(p_note), ''), jsonb_build_object('return_total', v_return.return_total, 'settlement', p_settlement));

  return query select v_return.id, v_return.return_number;
end;
$$;

revoke all on function public.create_sales_return(text, uuid, boolean, text, text, text, jsonb, uuid) from public, anon;
grant execute on function public.create_sales_return(text, uuid, boolean, text, text, text, jsonb, uuid) to authenticated;

-- Module 09 Invoices. Cash walk-in sales carry wholesaler_id = null and
-- is_cash_walk_in = true (no khata concept at all); real wholesaler sales
-- always have a wholesaler_id and go through the khata_entries ledger via
-- apply_khata_entry(), same trigger pattern as Sales Return / Wholesalers.
create sequence if not exists public.invoice_number_seq;

create table public.invoices (
  id uuid primary key default gen_random_uuid(),
  invoice_number text not null unique
    default ('INV-' || lpad(nextval('public.invoice_number_seq')::text, 4, '0')),
  status text not null default 'draft'
    check (status in ('draft', 'invoiced', 'dispatched', 'cancelled')),
  sale_type text not null default 'wholesaler'
    check (sale_type in ('wholesaler', 'mechanic', 'customer')),
  is_cash_walk_in boolean not null default false,
  wholesaler_id uuid references public.wholesalers(id),
  cashier_id uuid references public.profiles(id),
  invoice_date date not null default current_date,
  bill_discount numeric(12, 2) not null default 0 check (bill_discount >= 0),
  bill_discount_is_percent boolean not null default false,
  subtotal numeric(12, 2) not null default 0 check (subtotal >= 0),
  payable_total numeric(12, 2) not null default 0 check (payable_total >= 0),
  previous_khata numeric(12, 2) not null default 0,
  cash_received numeric(12, 2) not null default 0 check (cash_received >= 0),
  payment_method text
    check (payment_method is null or payment_method in ('cash', 'bank_transfer', 'cheque', 'jazzcash', 'easypaisa')),
  notes text check (notes is null or char_length(notes) <= 500),
  issued_at timestamptz,
  dispatched_at timestamptz,
  cancelled_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid references public.profiles(id),
  updated_by uuid references public.profiles(id),
  constraint invoices_wholesaler_requires_account check (
    (is_cash_walk_in and wholesaler_id is null) or
    (not is_cash_walk_in and wholesaler_id is not null)
  )
);

comment on table public.invoices is
  'Wholesale/mechanic/customer counter invoices. Cash walk-in sales have wholesaler_id = null and no khata effect.';

create index invoices_wholesaler_id_idx on public.invoices (wholesaler_id);
create index invoices_status_idx on public.invoices (status);
create index invoices_invoice_date_idx on public.invoices (invoice_date desc);

alter table public.invoices enable row level security;

create policy invoices_select_staff on public.invoices
  for select using ((select private.is_staff()));
create policy invoices_insert_staff on public.invoices
  for insert with check ((select private.is_staff()));
create policy invoices_update_staff on public.invoices
  for update using ((select private.is_staff())) with check ((select private.is_staff()));

create trigger invoices_updated_at
  before update on public.invoices
  for each row execute function public.handle_updated_at();

-- Line items. Prices/rewards are frozen at issue time (Snapshot Principle,
-- Module 09 spec) - never re-derived from live products/schemes rows.
create table public.invoice_lines (
  id uuid primary key default gen_random_uuid(),
  invoice_id uuid not null references public.invoices(id) on delete cascade,
  product_id uuid not null references public.products(id),
  product_name_snapshot text not null,
  product_code_snapshot text not null,
  brand_snapshot text,
  buying_price_snapshot numeric(12, 2) not null check (buying_price_snapshot > 0),
  selling_price_snapshot numeric(12, 2) not null check (selling_price_snapshot > 0),
  quantity integer not null check (quantity > 0),
  has_active_scheme boolean not null default false,
  mechanic_reward_snapshot integer not null default 0 check (mechanic_reward_snapshot >= 0),
  wholesaler_reward_snapshot integer not null default 0 check (wholesaler_reward_snapshot >= 0),
  qr_count integer not null default 0 check (qr_count >= 0),
  created_at timestamptz not null default now()
);

comment on table public.invoice_lines is
  'Snapshot line items for an invoice. qr_count is a dummy/preview count until Module 10 (QR Codes) exists - no qr_codes table yet.';

create index invoice_lines_invoice_id_idx on public.invoice_lines (invoice_id);
create index invoice_lines_product_id_idx on public.invoice_lines (product_id);

alter table public.invoice_lines enable row level security;

create policy invoice_lines_select_staff on public.invoice_lines
  for select using ((select private.is_staff()));
create policy invoice_lines_insert_staff on public.invoice_lines
  for insert with check ((select private.is_staff()));
create policy invoice_lines_update_staff on public.invoice_lines
  for update using ((select private.is_staff())) with check ((select private.is_staff()));
create policy invoice_lines_delete_staff on public.invoice_lines
  for delete using ((select private.is_staff()));

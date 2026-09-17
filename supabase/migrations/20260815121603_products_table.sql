-- ============================================================
-- products
-- ============================================================

create table public.products (
  id uuid primary key default gen_random_uuid(),

  -- Basic info
  name text not null
    check (char_length(name) between 2 and 200),

  description text
    check (description is null or char_length(description) <= 500),

  category_id smallint not null
    references public.categories(id) on delete restrict,

  -- Brand is required (confirmed against Module 03 spec; Zod to be tightened to match).
  brand_id smallint not null
    references public.brands(id) on delete restrict,

  -- Pricing, PKR, 2dp
  buying_price numeric(10, 2) not null
    check (buying_price > 0 and buying_price <= 999999.99),
  customer_price numeric(10, 2) not null
    check (customer_price > 0 and customer_price <= 999999.99),
  mechanic_price numeric(10, 2) not null
    check (mechanic_price > 0 and mechanic_price <= 999999.99),
  wholesaler_price numeric(10, 2) not null
    check (wholesaler_price > 0 and wholesaler_price <= 999999.99),
  discount_price numeric(10, 2)
    check (discount_price is null or (discount_price > 0 and discount_price <= 999999.99)),

  -- Mirrors the Zod rule in lib/validations/product.ts: a discount must
  -- actually be a discount.
  constraint products_discount_below_customer_price
    check (discount_price is null or discount_price < customer_price),

  -- Inventory. Derived from stock_adjustments via trigger; never written directly.
  stock integer not null default 0
    check (stock >= 0 and stock <= 999999),

  -- Visibility in the customer app
  show_to_customers boolean not null default true,

  -- Audit
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid references public.profiles(id) on delete set null,
  updated_by uuid references public.profiles(id) on delete set null,

  -- Soft delete (no UI yet)
  deleted_at timestamptz
);

create index products_category_idx on public.products (category_id);
create index products_brand_idx on public.products (brand_id);
create index products_created_by_idx on public.products (created_by);
create index products_updated_by_idx on public.products (updated_by);
create index products_created_at_idx on public.products (created_at desc);

-- Live catalog lookups skip soft-deleted rows.
create index products_active_idx on public.products (name) where deleted_at is null;
create index products_customer_visible_idx on public.products (show_to_customers)
  where deleted_at is null and show_to_customers = true;

-- Case-insensitive name uniqueness among live products, backing the
-- duplicate-name dialog in the product form.
create unique index products_name_unique_active on public.products (lower(name))
  where deleted_at is null;

create trigger products_updated_at
before update on public.products
for each row execute function public.handle_updated_at();

-- ------------------------------------------------------------
-- RLS: staff only. buying_price, mechanic_price and wholesaler_price
-- must never reach the Flutter apps; those read restricted views
-- (added with their own modules), not this table.
-- ------------------------------------------------------------
alter table public.products enable row level security;

create policy products_select_staff on public.products
for select to authenticated
using ((select private.is_staff()));

create policy products_write_staff on public.products
for all to authenticated
using ((select private.is_staff()))
with check ((select private.is_staff()));

grant select, insert, update, delete on public.products to authenticated;

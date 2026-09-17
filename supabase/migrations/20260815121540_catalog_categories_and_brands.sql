-- ============================================================
-- Catalog reference data: categories and brands
-- ============================================================

create table public.categories (
  id smallint primary key generated always as identity,

  name text not null
    check (char_length(name) between 2 and 50),

  slug text not null
    check (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),

  sort_order smallint not null default 0
    check (sort_order between 1 and 999),

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid references public.profiles(id) on delete set null,
  updated_by uuid references public.profiles(id) on delete set null,

  constraint categories_slug_unique unique (slug)
);

-- Case-insensitive uniqueness on name (cannot live in a table constraint).
create unique index categories_name_unique on public.categories (lower(name));
create index categories_sort_order_idx on public.categories (sort_order);
create index categories_created_by_idx on public.categories (created_by);
create index categories_updated_by_idx on public.categories (updated_by);

create trigger categories_updated_at
before update on public.categories
for each row execute function public.handle_updated_at();

-- ------------------------------------------------------------

create table public.brands (
  id smallint primary key generated always as identity,

  name text not null
    check (char_length(name) between 2 and 50),

  is_default boolean not null default false,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid references public.profiles(id) on delete set null,
  updated_by uuid references public.profiles(id) on delete set null
);

create unique index brands_name_unique on public.brands (lower(name));
-- At most one default brand across the table.
create unique index brands_default_idx on public.brands (is_default) where is_default = true;
create index brands_created_by_idx on public.brands (created_by);
create index brands_updated_by_idx on public.brands (updated_by);

create trigger brands_updated_at
before update on public.brands
for each row execute function public.handle_updated_at();

-- ------------------------------------------------------------
-- Seed from the admin panel's dummy data
-- ------------------------------------------------------------
insert into public.categories (name, slug, sort_order) values
  ('Mobile Oil',  'mobile-oil',  1),
  ('Brake Pads',  'brake-pads',  2),
  ('Filters',     'filters',     3),
  ('Chains',      'chains',      4),
  ('Spark Plugs', 'spark-plugs', 5),
  ('Bearings',    'bearings',    6),
  ('Gaskets',     'gaskets',     7),
  ('Cables',      'cables',      8),
  ('Other',       'other',       9);

insert into public.brands (name, is_default) values
  ('SGX',       true),
  ('Total',     false),
  ('Shell',     false),
  ('NGK',       false),
  ('Honda OEM', false),
  ('Generic',   false);

-- ------------------------------------------------------------
-- RLS: readable by any signed-in user (the apps need category and
-- brand names for the catalog); only staff may write.
-- ------------------------------------------------------------
alter table public.categories enable row level security;
alter table public.brands enable row level security;

create policy categories_select_authenticated on public.categories
for select to authenticated
using (true);

create policy categories_write_staff on public.categories
for all to authenticated
using ((select private.is_staff()))
with check ((select private.is_staff()));

create policy brands_select_authenticated on public.brands
for select to authenticated
using (true);

create policy brands_write_staff on public.brands
for all to authenticated
using ((select private.is_staff()))
with check ((select private.is_staff()));

grant select, insert, update, delete on public.categories to authenticated;
grant select, insert, update, delete on public.brands to authenticated;

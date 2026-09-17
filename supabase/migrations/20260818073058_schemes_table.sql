-- ============================================================
-- schemes
-- ============================================================

create table public.schemes (
  id uuid primary key default gen_random_uuid(),

  -- One scheme per product, ever.
  product_id uuid not null unique
    references public.products(id) on delete cascade,

  mechanic_points integer not null
    check (mechanic_points >= 0 and mechanic_points <= 999),
  wholesaler_points integer not null
    check (wholesaler_points >= 0 and wholesaler_points <= 999),

  -- At least one share must be positive.
  constraint schemes_at_least_one_share_positive
    check (mechanic_points > 0 or wholesaler_points > 0),

  is_active boolean not null default true,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid references public.profiles(id) on delete set null,
  updated_by uuid references public.profiles(id) on delete set null
);

create index schemes_product_idx on public.schemes (product_id);
create index schemes_active_idx on public.schemes (product_id) where is_active = true;
create index schemes_created_by_idx on public.schemes (created_by);
create index schemes_updated_by_idx on public.schemes (updated_by);

create trigger schemes_updated_at
before update on public.schemes
for each row execute function public.handle_updated_at();

-- ------------------------------------------------------------
-- RLS: staff only. Mirrors products/claims split-policy shape.
-- ------------------------------------------------------------
alter table public.schemes enable row level security;

create policy schemes_select_staff on public.schemes
for select to authenticated
using ((select private.is_staff()));

create policy schemes_insert_staff on public.schemes
for insert to authenticated
with check ((select private.is_staff()));

create policy schemes_update_staff on public.schemes
for update to authenticated
using ((select private.is_staff()))
with check ((select private.is_staff()));

create policy schemes_delete_staff on public.schemes
for delete to authenticated
using ((select private.is_staff()));

grant select, insert, update, delete on public.schemes to authenticated;

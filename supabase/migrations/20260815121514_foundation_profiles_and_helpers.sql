-- ============================================================
-- Foundation: helper schema, shared trigger fn, profiles table
-- ============================================================

create schema if not exists private;
revoke all on schema private from public, anon, authenticated;

-- Shared updated_at trigger function used by every auditable table.
create or replace function public.handle_updated_at()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- ------------------------------------------------------------
-- profiles: one row per auth user, across all three apps.
-- Internal staff roles are created via Settings > Staff.
-- App roles self-register through the Flutter apps.
-- ------------------------------------------------------------
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,

  full_name text not null
    check (char_length(full_name) between 2 and 100),

  phone text
    check (phone is null or phone ~ '^\+?[0-9]{10,15}$'),

  avatar_url text,

  role text not null
    check (role in (
      -- internal staff (admin panel)
      'admin',
      'manager',
      'collector',
      'counter_staff',
      -- app users (Flutter)
      'wholesaler',
      'mechanic',
      'customer'
    )),

  is_active boolean not null default true,
  deactivated_at timestamptz,
  deactivation_reason text
    check (deactivation_reason is null or char_length(deactivation_reason) <= 500),

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index profiles_role_idx on public.profiles (role);
create index profiles_is_active_idx on public.profiles (is_active) where is_active = true;

create trigger profiles_updated_at
before update on public.profiles
for each row execute function public.handle_updated_at();

-- ------------------------------------------------------------
-- Staff check. SECURITY DEFINER so RLS policies on profiles can
-- call it without recursing into profiles' own policies.
-- Always scoped to the calling user's own row.
-- ------------------------------------------------------------
create or replace function private.is_staff()
returns boolean
language sql
security definer
stable
set search_path = ''
as $$
  select exists (
    select 1
    from public.profiles p
    where p.id = (select auth.uid())
      and p.is_active = true
      and p.role in ('admin', 'manager', 'collector', 'counter_staff')
  );
$$;

create or replace function private.is_admin()
returns boolean
language sql
security definer
stable
set search_path = ''
as $$
  select exists (
    select 1
    from public.profiles p
    where p.id = (select auth.uid())
      and p.is_active = true
      and p.role = 'admin'
  );
$$;

revoke execute on function private.is_staff() from public, anon;
revoke execute on function private.is_admin() from public, anon;
grant usage on schema private to authenticated;
grant execute on function private.is_staff() to authenticated;
grant execute on function private.is_admin() to authenticated;

-- ------------------------------------------------------------
-- RLS
-- ------------------------------------------------------------
alter table public.profiles enable row level security;

create policy profiles_select_own on public.profiles
for select to authenticated
using ((select auth.uid()) = id);

create policy profiles_select_staff on public.profiles
for select to authenticated
using ((select private.is_staff()));

create policy profiles_update_own on public.profiles
for update to authenticated
using ((select auth.uid()) = id)
with check ((select auth.uid()) = id);

create policy profiles_update_staff on public.profiles
for update to authenticated
using ((select private.is_staff()))
with check ((select private.is_staff()));

create policy profiles_insert_staff on public.profiles
for insert to authenticated
with check ((select private.is_staff()));

-- Data API exposure (no longer automatic for new tables).
grant select, insert, update on public.profiles to authenticated;

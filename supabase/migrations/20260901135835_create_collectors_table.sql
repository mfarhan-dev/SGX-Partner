-- ============================================================
-- Collectors: standalone, non-auth entities who physically
-- collect cash from wholesalers. Never log in, never get a
-- profiles row (profiles.id is FK'd to auth.users.id) - just a
-- name staff can pick from when recording a khata payment.
--
-- khata_entries keeps BOTH attribution columns:
--   created_by   - the staff member (profiles) who recorded the entry
--   collected_by - the staff member (profiles), if a staff member
--                  physically took the money themselves
--   collector_id - the collector (this table), if a dedicated
--                  collector brought the cash back instead
-- A payment can name a collector, a staff collected_by, both, or
-- neither (e.g. wholesaler paid directly at the counter).
-- ============================================================

create table public.collectors (
  id uuid primary key default gen_random_uuid(),

  name text not null
    check (char_length(name) between 2 and 100),

  is_active boolean not null default true,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  created_by uuid references public.profiles(id),
  updated_by uuid references public.profiles(id)
);

create index collectors_is_active_idx on public.collectors (is_active) where is_active = true;

create trigger collectors_updated_at
before update on public.collectors
for each row execute function public.handle_updated_at();

alter table public.collectors enable row level security;

create policy collectors_select_staff on public.collectors
for select to authenticated
using ((select private.is_staff()));

create policy collectors_insert_staff on public.collectors
for insert to authenticated
with check ((select private.is_staff()));

create policy collectors_update_staff on public.collectors
for update to authenticated
using ((select private.is_staff()))
with check ((select private.is_staff()));

grant select, insert, update on public.collectors to authenticated;

-- ------------------------------------------------------------
-- khata_entries.collector_id - mirrors collected_by's shape and
-- constraint (only settable on a payment entry).
-- ------------------------------------------------------------
alter table public.khata_entries
  add column collector_id uuid references public.collectors(id) on delete set null;

alter table public.khata_entries
  add constraint khata_entries_collector_id_on_payment
    check (collector_id is null or entry_type = 'payment');

create index khata_entries_collector_id_idx
  on public.khata_entries (collector_id);

-- ------------------------------------------------------------
-- Drop 'collector' as a profiles.role value - collectors are not
-- staff accounts and never authenticate.
-- ------------------------------------------------------------
alter table public.profiles
  drop constraint profiles_role_check;

alter table public.profiles
  add constraint profiles_role_check
    check (role in (
      -- internal staff (admin panel)
      'admin',
      'manager',
      'counter_staff',
      -- app users (Flutter)
      'wholesaler',
      'mechanic',
      'customer'
    ));

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
      and p.role in ('admin', 'manager', 'counter_staff')
  );
$$;

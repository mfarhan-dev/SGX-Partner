
create table public.payout_accounts (
  id uuid primary key default gen_random_uuid(),
  mechanic_id uuid references public.mechanics(id) on delete cascade,
  wholesaler_id uuid references public.wholesalers(id) on delete cascade,
  provider text not null check (provider in (
    'easy_paisa', 'jazz_cash', 'sada_pay', 'naya_pay', 'u_paisa',
    'meezan_bank', 'hbl', 'ubl', 'mcb_bank', 'bank_alfalah',
    'allied_bank', 'askari_bank', 'faysal_bank', 'bank_al_habib', 'nbp'
  )),
  account_title text not null,
  account_number text not null,
  is_default boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid references public.profiles(id),
  updated_by uuid references public.profiles(id),
  constraint payout_accounts_owner_check check (
    (mechanic_id is not null and wholesaler_id is null) or
    (mechanic_id is null and wholesaler_id is not null)
  )
);

comment on table public.payout_accounts is
  'One or more saved payout channels per partner (mechanic or wholesaler). Replaces the old single payout_method/payout_account_title/payout_account_number columns on mechanics/wholesalers -- those columns are left in place, unused, for safety but are no longer read or written by the app.';

-- Only one default account per owner.
create unique index payout_accounts_one_default_mechanic
  on public.payout_accounts (mechanic_id)
  where is_default and mechanic_id is not null;

create unique index payout_accounts_one_default_wholesaler
  on public.payout_accounts (wholesaler_id)
  where is_default and wholesaler_id is not null;

create index payout_accounts_mechanic_id_idx on public.payout_accounts (mechanic_id);
create index payout_accounts_wholesaler_id_idx on public.payout_accounts (wholesaler_id);

alter table public.payout_accounts enable row level security;

-- Owner can read their own saved accounts; mutations only via SECURITY
-- DEFINER RPCs below (same pattern as mechanics/wholesalers: no direct
-- insert/update/delete policy for the partner themselves).
create policy payout_accounts_select_self on public.payout_accounts
  for select
  using (
    mechanic_id in (select id from public.mechanics where profile_id = (select auth.uid()))
    or wholesaler_id in (select id from public.wholesalers where profile_id = (select auth.uid()))
  );

create policy payout_accounts_select_staff on public.payout_accounts
  for select
  using (private.is_staff());

create policy payout_accounts_staff_all on public.payout_accounts
  for all
  using (private.is_staff())
  with check (private.is_staff());

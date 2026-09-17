create sequence public.withdrawal_number_seq;

create table public.withdrawals (
  id uuid primary key default gen_random_uuid(),
  withdrawal_no text not null unique
    default ('WD-' || lpad(nextval('public.withdrawal_number_seq')::text, 4, '0')),

  -- Exactly one of these is set, same convention as qr_codes.mechanic_id /
  -- qr_codes.wholesaler_id.
  mechanic_id uuid references public.mechanics(id),
  wholesaler_id uuid references public.wholesalers(id),
  constraint withdrawals_exactly_one_subject check (
    (mechanic_id is not null and wholesaler_id is null) or
    (mechanic_id is null and wholesaler_id is not null)
  ),

  -- Whole rupees, same unit as mechanics.points_balance /
  -- wholesalers.points_balance -- this is what gets deducted from (and,
  -- on refund, added back to) that guarded running balance.
  amount integer not null check (amount > 0),

  method text not null check (method in ('easy_paisa', 'jazz_cash', 'bank_transfer', 'cash_collection')),
  account_title text not null,
  account_number text not null,

  -- Mirrors WithdrawalStatus in the Flutter app exactly.
  status text not null default 'pending'
    check (status in ('pending', 'payment_sent', 'confirmed', 'disputed', 'auto_confirmed', 'refunded')),

  dispute_reason text,
  staff_note text,

  requested_at timestamptz not null default now(),
  payment_sent_at timestamptz,
  confirmed_at timestamptz,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid references public.profiles(id),
  updated_by uuid references public.profiles(id)
);

comment on table public.withdrawals is
  'A mechanic''s or wholesaler''s cash-out request against their points_balance. Requesting deducts the balance immediately (reserved); confirming/disputing/refunding is the partner''s own action on a payment staff already marked as sent from the separate admin panel. Status changes only through request_withdrawal()/confirm_withdrawal_received()/dispute_withdrawal_received() plus staff actions -- never a direct row update.';

create index withdrawals_mechanic_id_idx on public.withdrawals(mechanic_id) where mechanic_id is not null;
create index withdrawals_wholesaler_id_idx on public.withdrawals(wholesaler_id) where wholesaler_id is not null;
create index withdrawals_status_idx on public.withdrawals(status);

alter table public.withdrawals enable row level security;

-- Partners only ever read their own withdrawals -- all writes happen
-- through SECURITY DEFINER RPCs (built next), never directly against
-- this table by a partner.
create policy withdrawals_select_own_mechanic on public.withdrawals
  for select to authenticated
  using (
    mechanic_id in (select id from public.mechanics where profile_id = (select auth.uid()))
  );

create policy withdrawals_select_own_wholesaler on public.withdrawals
  for select to authenticated
  using (
    wholesaler_id in (select id from public.wholesalers where profile_id = (select auth.uid()))
  );

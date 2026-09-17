-- Real backing for the mechanic "Wallet"/Activity screen (previously
-- 100% mock -- see handoff.md gap #1). No pre-existing ledger table
-- covers this (khata_entries is wholesaler-only), and audit_logs does
-- not capture QR-scan-reward events or "withdrawal requested" at all,
-- so this reconstructs the feed straight from the two tables that
-- actually hold the data, following get_khata_ledger's own pattern
-- (STABLE SECURITY DEFINER, scoped to auth.uid() server-side).

create or replace function public.get_mechanic_wallet_summary()
returns table(available integer, pending integer, lifetime_earned integer)
language sql
stable security definer
set search_path to ''
as $$
  select
    m.points_balance as available,
    coalesce((
      select sum(w.amount) from public.withdrawals w
      where w.mechanic_id = m.id and w.status in ('pending', 'payment_sent', 'disputed')
    ), 0)::integer as pending,
    coalesce((
      select sum(q.mechanic_reward_snapshot) from public.qr_codes q
      where q.mechanic_id = m.id and q.status = 'scanned'
    ), 0)::integer as lifetime_earned
  from public.mechanics m
  where m.profile_id = (select auth.uid());
$$;

create or replace function public.get_mechanic_wallet_activity()
returns table(
  id text,
  entry_type text,
  occurred_at timestamptz,
  amount integer,
  status text,
  withdrawal_id uuid,
  reference text,
  note text
)
language sql
stable security definer
set search_path to ''
as $$
  with me as (
    select id from public.mechanics where profile_id = (select auth.uid())
  ),
  feed as (
    -- One row per confirmed scan reward.
    select
      'qr:' || q.id::text as id, 'qr_reward' as entry_type, q.scanned_at as occurred_at,
      q.mechanic_reward_snapshot as amount, 'confirmed' as status,
      null::uuid as withdrawal_id, q.qr_id as reference, p.name as note
    from public.qr_codes q
    join me on me.id = q.mechanic_id
    left join public.products p on p.id = q.product_id
    where q.status = 'scanned'

    union all
    -- One row per withdrawal LIFECYCLE EVENT, unpivoted off the
    -- withdrawal's own timestamp columns (mirrors the transitions
    -- enforce_withdrawal_status_transition() actually allows). A
    -- withdrawal can contribute up to 4 rows here as it progresses.
    select
      w.id::text || ':requested', 'withdrawal_requested', w.requested_at, -w.amount,
      'requested', w.id, w.withdrawal_no, null
    from public.withdrawals w join me on me.id = w.mechanic_id
    where w.requested_at is not null

    union all
    select
      w.id::text || ':payment_sent', 'payment_sent', w.payment_sent_at, null,
      'payment_sent', w.id, w.withdrawal_no, null
    from public.withdrawals w join me on me.id = w.mechanic_id
    where w.payment_sent_at is not null

    union all
    select
      w.id::text || ':confirmed', 'withdrawal_confirmed', w.confirmed_at, null,
      'confirmed', w.id, w.withdrawal_no, null
    from public.withdrawals w join me on me.id = w.mechanic_id
    where w.confirmed_at is not null and w.status = 'confirmed'

    union all
    select
      w.id::text || ':auto_confirmed', 'withdrawal_auto_confirmed', w.confirmed_at, null,
      'auto_confirmed', w.id, w.withdrawal_no, null
    from public.withdrawals w join me on me.id = w.mechanic_id
    where w.confirmed_at is not null and w.status = 'auto_confirmed'

    union all
    select
      w.id::text || ':disputed', 'withdrawal_disputed', w.disputed_at, null,
      'disputed', w.id, w.withdrawal_no, w.dispute_reason
    from public.withdrawals w join me on me.id = w.mechanic_id
    where w.disputed_at is not null

    union all
    select
      w.id::text || ':refunded', 'withdrawal_refunded', w.refunded_at, w.amount,
      'refunded', w.id, w.withdrawal_no, w.refund_note
    from public.withdrawals w join me on me.id = w.mechanic_id
    where w.refunded_at is not null
  )
  select * from feed order by occurred_at desc;
$$;

create or replace function public.get_withdrawal_dispute_events(p_withdrawal_id uuid)
returns table (created_at timestamp with time zone, reason text)
language plpgsql
security definer
set search_path to ''
as $$
declare
  v_withdrawal_no text;
begin
  select w.withdrawal_no into v_withdrawal_no
  from public.withdrawals w
  where w.id = p_withdrawal_id
    and (
      w.mechanic_id in (select id from public.mechanics where profile_id = (select auth.uid()))
      or w.wholesaler_id in (select id from public.wholesalers where profile_id = (select auth.uid()))
    );

  if v_withdrawal_no is null then
    raise exception 'Withdrawal not found' using errcode = '28000';
  end if;

  -- Every time this partner disputed this withdrawal, in order: the first
  -- row is the original dispute, any further rows are a repeat dispute
  -- after a re-pay. Each carries its own reason from that exact moment,
  -- since the withdrawals row itself only ever keeps the latest
  -- dispute_reason/disputed_at and overwrites it on a repeat dispute.
  return query
    select al.created_at, al.note as reason
    from public.audit_logs al
    where al.module = 'Withdrawals'
      and al.target = v_withdrawal_no
      and al.action like 'Disputed by %'
    order by al.created_at asc;
end;
$$;

revoke all on function public.get_withdrawal_dispute_events(uuid) from public;
revoke all on function public.get_withdrawal_dispute_events(uuid) from anon;
grant execute on function public.get_withdrawal_dispute_events(uuid) to authenticated;

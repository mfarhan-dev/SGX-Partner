create or replace function public.get_withdrawal_repayment_events(p_withdrawal_id uuid)
returns table (created_at timestamptz, proof_storage_path text)
language plpgsql
security definer
set search_path = ''
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

  -- Every time SGX marked this withdrawal paid, in order: the first row is
  -- the original payment, any further rows are a re-pay after a dispute.
  -- Each one carries its own proof screenshot from that exact moment
  -- (after_snapshot), since the withdrawals row itself only ever keeps the
  -- latest payment_sent_at/proof_storage_path and overwrites it on re-pay.
  return query
    select al.created_at, al.after_snapshot->>'proof_storage_path' as proof_storage_path
    from public.audit_logs al
    where al.module = 'Withdrawals'
      and al.target = v_withdrawal_no
      and al.action in ('Marked Paid by admin', 'Re-paid by admin')
    order by al.created_at asc;
end;
$$;

revoke execute on function public.get_withdrawal_repayment_events(uuid) from public;
revoke execute on function public.get_withdrawal_repayment_events(uuid) from anon;
grant execute on function public.get_withdrawal_repayment_events(uuid) to authenticated;

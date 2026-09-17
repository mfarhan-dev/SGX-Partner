create or replace function public.get_wholesaler_wallet_summary()
returns table (available integer, pending integer, lifetime_earned integer)
language sql
stable
security definer
set search_path to ''
as $$
  select
    w.points_balance as available,
    coalesce((
      select sum(wd.amount) from public.withdrawals wd
      where wd.wholesaler_id = w.id and wd.status in ('pending', 'payment_sent', 'disputed')
    ), 0)::integer as pending,
    coalesce((
      select sum(q.wholesaler_reward_snapshot) from public.qr_codes q
      where q.wholesaler_id = w.id and q.status = 'scanned'
    ), 0)::integer as lifetime_earned
  from public.wholesalers w
  where w.profile_id = (select auth.uid());
$$;

revoke all on function public.get_wholesaler_wallet_summary() from public;
revoke all on function public.get_wholesaler_wallet_summary() from anon;
grant execute on function public.get_wholesaler_wallet_summary() to authenticated;

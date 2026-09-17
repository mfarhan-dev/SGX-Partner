-- These two new RPCs got PostgreSQL's default PUBLIC execute grant,
-- unlike every other partner-scoped RPC in this project (e.g.
-- get_khata_ledger), which has anon/PUBLIC explicitly revoked. Match
-- that: signed-out calls should not reach this function at all, even
-- though auth.uid() being null already makes them return zero rows.
revoke execute on function public.get_mechanic_wallet_summary() from public;
revoke execute on function public.get_mechanic_wallet_activity() from public;
grant execute on function public.get_mechanic_wallet_summary() to authenticated;
grant execute on function public.get_mechanic_wallet_activity() to authenticated;

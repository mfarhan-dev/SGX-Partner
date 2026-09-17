-- Supabase's schema-level default privileges grant EXECUTE to anon
-- explicitly (not just via PUBLIC) on every new function, which is why
-- the previous revoke-from-public migration didn't fully match
-- get_khata_ledger's access (which has no anon grant at all). Revoke
-- the explicit anon grant too.
revoke execute on function public.get_mechanic_wallet_summary() from anon;
revoke execute on function public.get_mechanic_wallet_activity() from anon;

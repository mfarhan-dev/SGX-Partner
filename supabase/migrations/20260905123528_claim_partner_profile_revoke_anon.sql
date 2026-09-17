-- Supabase grants EXECUTE on new public functions to anon by default
-- regardless of a bare "revoke ... from public". claim_partner_profile
-- reads auth.uid()/auth.users for the CALLER, so it must never be
-- reachable without a session -- explicitly close that off.
revoke execute on function public.claim_partner_profile() from anon;

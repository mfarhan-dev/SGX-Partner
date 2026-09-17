-- ============================================================
-- check_partner_phone(phone): the gate before OTP is sent.
--
-- wholesalers/mechanics SELECT is staff-only by RLS, so an
-- unauthenticated login screen can't query them directly. This
-- SECURITY DEFINER function bypasses RLS on purpose, but exposes
-- only the one bit the login screen needs (which role, if any) —
-- never shop name, khata balance, CNIC, or any other field.
--
-- Called by: the app right after the user types a phone number,
-- before signInWithOtp. Deactivated accounts are treated as
-- "not found" so a deactivated wholesaler falls through the same
-- as an unknown number.
-- ============================================================

create or replace function public.check_partner_phone(p_phone text)
returns text
language sql
security definer
set search_path = ''
stable
as $$
  select case
    when exists (
      select 1 from public.wholesalers w
      where w.phone = p_phone and w.is_active
    ) then 'wholesaler'
    when exists (
      select 1 from public.mechanics m
      where m.phone = p_phone and m.is_active
    ) then 'mechanic'
    else null
  end;
$$;

revoke all on function public.check_partner_phone(text) from public;
grant execute on function public.check_partner_phone(text) to anon, authenticated;

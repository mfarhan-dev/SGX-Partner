-- ============================================================
-- claim_partner_profile(): runs immediately after a successful
-- verifyOTP, as the newly authenticated user.
--
-- Never trusts a client-supplied phone number -- it reads the
-- CALLER's own verified phone straight from auth.users, so nobody
-- can claim someone else's wholesaler/mechanic record by passing a
-- different phone in. Idempotent: a repeat login just returns the
-- already-claimed profile, no re-insert.
--
-- Returns a row shaped like the app's ProfileSummary:
--   id, display_name, phone_number, role, is_active, is_complete
--
-- is_complete:
--   wholesaler -> true the moment a wholesalers row is claimed
--     (staff already filled in everything needed).
--   mechanic, matched to a pre-created mechanics row -> true, same reason.
--   mechanic, no match anywhere -> false; the app must run the
--     onboarding form, which creates the real mechanics row and
--     sets its profile_id (a follow-up migration/RPC, not this one).
-- ============================================================

create or replace function public.claim_partner_profile()
returns table (
  id uuid,
  display_name text,
  phone_number text,
  role text,
  is_active boolean,
  is_complete boolean
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_phone text;
  v_wholesaler public.wholesalers%rowtype;
  v_mechanic public.mechanics%rowtype;
begin
  if v_uid is null then
    raise exception 'Not authenticated' using errcode = '28000';
  end if;

  -- Already claimed (repeat login) -- just report current state.
  if exists (select 1 from public.profiles p where p.id = v_uid) then
    return query
      select
        p.id,
        p.full_name,
        p.phone,
        p.role,
        p.is_active,
        case
          when p.role = 'wholesaler' then exists (
            select 1 from public.wholesalers w where w.profile_id = p.id
          )
          when p.role = 'mechanic' then exists (
            select 1 from public.mechanics m where m.profile_id = p.id
          )
          else true
        end
      from public.profiles p
      where p.id = v_uid;
    return;
  end if;

  select u.phone into v_phone from auth.users u where u.id = v_uid;
  if v_phone is null or v_phone = '' then
    raise exception 'No verified phone on this account' using errcode = '22023';
  end if;

  -- 1) Wholesaler match.
  select * into v_wholesaler from public.wholesalers w
    where w.phone = v_phone and w.is_active and w.profile_id is null
    limit 1;

  if found then
    insert into public.profiles (id, full_name, phone, role)
    values (v_uid, v_wholesaler.owner_name, v_phone, 'wholesaler');

    update public.wholesalers set profile_id = v_uid where id = v_wholesaler.id;

    return query
      select v_uid, v_wholesaler.owner_name, v_phone, 'wholesaler'::text, true, true;
    return;
  end if;

  -- 2) Mechanic match (staff had pre-created this one too).
  select * into v_mechanic from public.mechanics m
    where m.phone = v_phone and m.is_active and m.profile_id is null
    limit 1;

  if found then
    insert into public.profiles (id, full_name, phone, role)
    values (v_uid, v_mechanic.full_name, v_phone, 'mechanic');

    update public.mechanics set profile_id = v_uid where id = v_mechanic.id;

    return query
      select v_uid, v_mechanic.full_name, v_phone, 'mechanic'::text, true, true;
    return;
  end if;

  -- 3) No match anywhere: brand-new mechanic self-signup. Seed a
  -- minimal profile; the onboarding form fills in the real
  -- mechanics row and full_name afterwards.
  insert into public.profiles (id, full_name, phone, role)
  values (v_uid, v_phone, v_phone, 'mechanic');

  return query
    select v_uid, v_phone, v_phone, 'mechanic'::text, true, false;
end;
$$;

revoke all on function public.claim_partner_profile() from public;
grant execute on function public.claim_partner_profile() to authenticated;

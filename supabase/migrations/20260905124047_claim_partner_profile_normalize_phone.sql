-- ============================================================
-- Fix: claim_partner_profile() compared auth.users.phone directly
-- against wholesalers/mechanics.phone. wholesalers/mechanics store
-- local Pakistani format (03XXXXXXXXX, 11 digits -- see their check
-- constraints), but Supabase Auth needs E.164 (+923XXXXXXXXX) to
-- actually deliver SMS, and stores auth.users.phone in that shape
-- (digits only, no "+"). Without normalizing, the two never match
-- and every login would fall through to "no match".
-- ============================================================

create or replace function private.normalize_pk_phone(p text)
returns text
language sql
immutable
set search_path = ''
as $$
  select case
    when p is null or p = '' then null
    -- E.164-ish: optional +, country code 92, then 10 digits -> 03XXXXXXXXX
    when regexp_replace(p, '[^0-9]', '', 'g') ~ '^92[0-9]{10}$'
      then '0' || right(regexp_replace(p, '[^0-9]', '', 'g'), 10)
    -- already local: 0 + 10 digits, first of the 10 being 3
    when regexp_replace(p, '[^0-9]', '', 'g') ~ '^03[0-9]{9}$'
      then regexp_replace(p, '[^0-9]', '', 'g')
    -- missing leading 0 but otherwise local shape
    when regexp_replace(p, '[^0-9]', '', 'g') ~ '^3[0-9]{9}$'
      then '0' || regexp_replace(p, '[^0-9]', '', 'g')
    else p
  end;
$$;

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
  v_phone_raw text;
  v_phone text;
  v_wholesaler public.wholesalers%rowtype;
  v_mechanic public.mechanics%rowtype;
begin
  if v_uid is null then
    raise exception 'Not authenticated' using errcode = '28000';
  end if;

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

  select u.phone into v_phone_raw from auth.users u where u.id = v_uid;
  v_phone := private.normalize_pk_phone(v_phone_raw);
  if v_phone is null then
    raise exception 'No verified phone on this account' using errcode = '22023';
  end if;

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

  insert into public.profiles (id, full_name, phone, role)
  values (v_uid, v_phone, v_phone, 'mechanic');

  return query
    select v_uid, v_phone, v_phone, 'mechanic'::text, true, false;
end;
$$;

revoke all on function public.claim_partner_profile() from public;
revoke execute on function public.claim_partner_profile() from anon;
grant execute on function public.claim_partner_profile() to authenticated;

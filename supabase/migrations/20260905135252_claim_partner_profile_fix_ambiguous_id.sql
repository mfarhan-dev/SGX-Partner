-- ============================================================
-- Fix: RETURNS TABLE(id uuid, ...) implicitly declares "id" as a
-- PL/pgSQL variable in scope, which collided with the bare "id"
-- column reference in the wholesalers/mechanics UPDATE statements
-- ("column reference \"id\" is ambiguous", error 42702). Alias the
-- target tables so the column reference is unambiguous.
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

    update public.wholesalers as w set profile_id = v_uid where w.id = v_wholesaler.id;

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

    update public.mechanics as m set profile_id = v_uid where m.id = v_mechanic.id;

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

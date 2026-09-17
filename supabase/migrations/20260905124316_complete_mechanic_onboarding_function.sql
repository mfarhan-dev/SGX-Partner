-- ============================================================
-- complete_mechanic_onboarding(): lets a brand-new mechanic (no
-- pre-created mechanics row) finish their own onboarding form.
--
-- mechanics INSERT is staff-only by RLS, so the mechanic can't
-- write this row directly. This function runs as them, but only
-- ever inserts a row for themselves (their own profile id and their
-- own verified phone from profiles, never client-supplied), and
-- only once (raises if they already have a claimed mechanics row).
-- ============================================================

create or replace function public.complete_mechanic_onboarding(
  p_full_name text,
  p_area text,
  p_address text default null
)
returns public.mechanics
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_phone text;
  v_role text;
  v_mechanic public.mechanics%rowtype;
begin
  if v_uid is null then
    raise exception 'Not authenticated' using errcode = '28000';
  end if;

  select role, phone into v_role, v_phone
  from public.profiles where id = v_uid;

  if v_role is null then
    raise exception 'No profile found for this session' using errcode = '22023';
  end if;

  if v_role is distinct from 'mechanic' then
    raise exception 'Only mechanic accounts can complete mechanic onboarding' using errcode = '42501';
  end if;

  if exists (select 1 from public.mechanics m where m.profile_id = v_uid) then
    raise exception 'Mechanic profile already completed' using errcode = '23505';
  end if;

  insert into public.mechanics (full_name, phone, area, address, profile_id, created_by, updated_by)
  values (p_full_name, v_phone, p_area, p_address, v_uid, v_uid, v_uid)
  returning * into v_mechanic;

  update public.profiles set full_name = p_full_name where id = v_uid;

  return v_mechanic;
end;
$$;

revoke all on function public.complete_mechanic_onboarding(text, text, text) from public;
revoke execute on function public.complete_mechanic_onboarding(text, text, text) from anon;
grant execute on function public.complete_mechanic_onboarding(text, text, text) to authenticated;

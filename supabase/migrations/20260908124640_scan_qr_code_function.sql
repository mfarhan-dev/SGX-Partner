-- The one entry point a mechanic's app calls when they scan a
-- physical QR sticker. Row-locks the code first so two simultaneous
-- scan attempts on the same code can't both succeed. Returns a plain
-- status string instead of raising for the expected "someone already
-- scanned this" / "not a real code" cases -- those are normal user
-- outcomes, not server errors.

create or replace function public.scan_qr_code(p_qr_id text)
returns table(
  result text,
  reward integer,
  new_balance integer
)
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_mechanic_id uuid;
  v_row public.qr_codes%rowtype;
begin
  select m.id into v_mechanic_id
  from public.mechanics m
  where m.profile_id = (select auth.uid()) and m.is_active;

  if v_mechanic_id is null then
    raise exception 'No active mechanic profile for this session' using errcode = '28000';
  end if;

  select * into v_row from public.qr_codes q where q.qr_id = p_qr_id for update;

  if not found then
    return query select 'not_found', null::integer, null::integer;
    return;
  end if;

  if v_row.status = 'scanned' then
    return query select 'already_scanned', null::integer, null::integer;
    return;
  end if;

  if v_row.status <> 'active' then
    return query select 'not_active', null::integer, null::integer;
    return;
  end if;

  update public.qr_codes
  set status = 'scanned', mechanic_id = v_mechanic_id
  where id = v_row.id;
  -- Fires enforce_qr_code_status_transition (sets scanned_at, validates
  -- the transition), the existing campaign-progress trigger, and
  -- credit_points_on_qr_scan (this migration's whole point) -- all
  -- automatically, from this one UPDATE.

  return query
    select
      'success',
      v_row.mechanic_reward_snapshot,
      (select mechanics.points_balance from public.mechanics where mechanics.id = v_mechanic_id);
end;
$function$;

revoke all on function public.scan_qr_code(text) from public;
revoke all on function public.scan_qr_code(text) from anon;
grant execute on function public.scan_qr_code(text) to authenticated;

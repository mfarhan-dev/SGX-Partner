drop function public.scan_qr_code(text);

-- Option A from the mechanic-scan UX discussion: when a QR is already
-- scanned, tell the scanning mechanic WHO already claimed it (name +
-- workshop only, never a phone number) so a false "I never got paid"
-- complaint can be settled on the spot, without handing out another
-- mechanic's contact details to whoever happens to scan their used
-- sticker.
create function public.scan_qr_code(p_qr_id text)
returns table(
  result text,
  reward integer,
  new_balance integer,
  scanned_by_name text,
  scanned_by_workshop text,
  scanned_at timestamptz
)
language plpgsql
security definer
set search_path to ''
as $$
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
    return query select 'not_found', null::integer, null::integer, null::text, null::text, null::timestamptz;
    return;
  end if;

  if v_row.status = 'scanned' then
    return query
      select
        'already_scanned', null::integer, null::integer,
        m.full_name, m.workshop_name, v_row.scanned_at
      from public.mechanics m
      where m.id = v_row.mechanic_id;
    return;
  end if;

  if v_row.status <> 'active' then
    return query select 'not_active', null::integer, null::integer, null::text, null::text, null::timestamptz;
    return;
  end if;

  update public.qr_codes
  set status = 'scanned', mechanic_id = v_mechanic_id
  where id = v_row.id;

  return query
    select
      'success',
      v_row.mechanic_reward_snapshot,
      (select mechanics.points_balance from public.mechanics where mechanics.id = v_mechanic_id),
      null::text, null::text, null::timestamptz;
end;
$$;

revoke execute on function public.scan_qr_code(text) from public;
revoke execute on function public.scan_qr_code(text) from anon;
grant execute on function public.scan_qr_code(text) to authenticated;

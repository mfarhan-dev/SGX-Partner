-- Fires only on the one legal generated->active->scanned transition
-- (enforce_qr_code_status_transition already guarantees this can only
-- happen once per code). Row-locks each party's own row before
-- reading their current balance, so two scans crediting the same
-- mechanic/wholesaler at the same moment can't race each other --
-- same safety property apply_khata_entry already has for khata_balance.

create or replace function private.credit_points_on_qr_scan()
returns trigger
language plpgsql
set search_path to ''
as $function$
begin
  if old.status = new.status or new.status <> 'scanned' then
    return new;
  end if;

  perform set_config('sgx.points_sync', 'on', true);

  if new.mechanic_id is not null and coalesce(new.mechanic_reward_snapshot, 0) > 0 then
    update public.mechanics
    set points_balance = points_balance + new.mechanic_reward_snapshot
    where id = new.mechanic_id;
  end if;

  if new.wholesaler_id is not null and coalesce(new.wholesaler_reward_snapshot, 0) > 0 then
    update public.wholesalers
    set points_balance = points_balance + new.wholesaler_reward_snapshot
    where id = new.wholesaler_id;
  end if;

  perform set_config('sgx.points_sync', 'off', true);

  return new;
end;
$function$;

create trigger qr_codes_credit_points_on_scan
  after update on public.qr_codes
  for each row execute function private.credit_points_on_qr_scan();

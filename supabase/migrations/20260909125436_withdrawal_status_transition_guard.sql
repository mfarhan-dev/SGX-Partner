create or replace function public.enforce_withdrawal_status_transition()
returns trigger language plpgsql set search_path to ''
as $function$
begin
  new.updated_at := now();

  if new.status = old.status then
    return new;
  end if;

  -- pending -> payment_sent / refunded (staff sends, or staff cancels
  --   before ever sending)
  -- payment_sent -> confirmed / disputed (partner's own action) /
  --   auto_confirmed (time-based, staff/cron)
  -- disputed -> confirmed / refunded (staff investigates and resolves)
  -- confirmed, auto_confirmed, refunded are terminal.
  if not (
    (old.status = 'pending' and new.status in ('payment_sent', 'refunded')) or
    (old.status = 'payment_sent' and new.status in ('confirmed', 'disputed', 'auto_confirmed')) or
    (old.status = 'disputed' and new.status in ('confirmed', 'refunded'))
  ) then
    raise exception 'Invalid withdrawal status transition: % -> %', old.status, new.status
      using errcode = '22023';
  end if;

  if new.status = 'payment_sent' and new.payment_sent_at is null then
    new.payment_sent_at := now();
  end if;

  if new.status in ('confirmed', 'auto_confirmed') and new.confirmed_at is null then
    new.confirmed_at := now();
  end if;

  return new;
end;
$function$;

create trigger withdrawals_status_transition_guard
  before update on public.withdrawals
  for each row execute function public.enforce_withdrawal_status_transition();

-- Refunding a withdrawal (staff resolving a dispute, or cancelling a
-- still-pending request) credits the reserved amount back -- same
-- guarded-flag pattern as credit_points_on_qr_scan, just in reverse.
create or replace function private.credit_points_on_withdrawal_refund()
returns trigger language plpgsql set search_path to ''
as $function$
begin
  if old.status = new.status or new.status <> 'refunded' then
    return new;
  end if;

  perform set_config('sgx.points_sync', 'on', true);

  if new.mechanic_id is not null then
    update public.mechanics set points_balance = points_balance + new.amount where id = new.mechanic_id;
  elsif new.wholesaler_id is not null then
    update public.wholesalers set points_balance = points_balance + new.amount where id = new.wholesaler_id;
  end if;

  perform set_config('sgx.points_sync', 'off', true);

  return new;
end;
$function$;

create trigger withdrawals_credit_on_refund
  after update on public.withdrawals
  for each row execute function private.credit_points_on_withdrawal_refund();

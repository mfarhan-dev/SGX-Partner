-- enforce_withdrawal_status_transition() never allowed disputed -> payment_sent,
-- but that's exactly what repayWithdrawal() (the admin panel's "Re-pay
-- Withdrawal" action) needs to do. Every re-pay attempt was being silently
-- rejected by this trigger -- the admin action returns an error, but from
-- the UI it just looks like "nothing happened."

create or replace function public.enforce_withdrawal_status_transition()
 returns trigger
 language plpgsql
 set search_path to ''
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
  -- disputed -> confirmed / refunded (staff investigates and resolves) /
  --   payment_sent (staff re-pays after investigating and sends again)
  -- confirmed, auto_confirmed, refunded are terminal.
  if not (
    (old.status = 'pending' and new.status in ('payment_sent', 'refunded')) or
    (old.status = 'payment_sent' and new.status in ('confirmed', 'disputed', 'auto_confirmed')) or
    (old.status = 'disputed' and new.status in ('confirmed', 'refunded', 'payment_sent'))
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

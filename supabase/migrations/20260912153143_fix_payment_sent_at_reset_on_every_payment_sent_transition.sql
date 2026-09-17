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

  -- Always the real moment of THIS transition into payment_sent, not
  -- just the first one: a re-pay after a dispute must reset this to
  -- now(), both so it displays correctly and because
  -- auto_confirm_stale_withdrawals() computes its 3-day window from
  -- this exact column -- leaving it pinned to the original payment
  -- would let a freshly re-paid withdrawal auto-confirm almost
  -- immediately if that original payment was already old.
  if new.status = 'payment_sent' then
    new.payment_sent_at := now();
  end if;

  if new.status in ('confirmed', 'auto_confirmed') and new.confirmed_at is null then
    new.confirmed_at := now();
  end if;

  return new;
end;
$function$;

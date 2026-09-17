-- Same gap as payment_sent: a withdrawal moving to 'refunded' silently
-- credits the balance back (credit_points_on_withdrawal_refund) but
-- notified nobody. Found while extending this exact function for
-- payment_sent; same class of bug, trivial to close in the same pass.
create or replace function public.notify_withdrawal_status_change()
returns trigger
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_profile_id uuid;
  v_route text;
begin
  if new.status = old.status then
    return new;
  end if;
  if new.status not in ('disputed', 'auto_confirmed', 'payment_sent', 'refunded') then
    return new;
  end if;

  if new.mechanic_id is not null then
    select profile_id into v_profile_id from public.mechanics where id = new.mechanic_id;
    v_route := '/mechanic/wallet';
  else
    select profile_id into v_profile_id from public.wholesalers where id = new.wholesaler_id;
    v_route := '/wholesaler/wallet';
  end if;

  if v_profile_id is null then
    return new;
  end if;

  if new.status = 'disputed' then
    insert into public.user_notifications (user_id, title, message, type, data)
    values (
      v_profile_id,
      'Withdrawal Disputed',
      'Your dispute for withdrawal ' || new.withdrawal_no || ' has been recorded. SGX will review it.',
      'withdrawal_disputed',
      jsonb_build_object('withdrawal_id', new.id, 'route', v_route)
    );
  elsif new.status = 'auto_confirmed' then
    insert into public.user_notifications (user_id, title, message, type, data)
    values (
      v_profile_id,
      'Withdrawal Auto-Confirmed',
      'Withdrawal ' || new.withdrawal_no || ' was automatically marked as received after no response.',
      'withdrawal_auto_confirmed',
      jsonb_build_object('withdrawal_id', new.id, 'route', v_route)
    );
  elsif new.status = 'payment_sent' then
    insert into public.user_notifications (user_id, title, message, type, data)
    values (
      v_profile_id,
      'Payment Sent',
      'Rs. ' || new.amount || ' has been sent for withdrawal ' || new.withdrawal_no || '. Please confirm once received.',
      'withdrawal_payment_sent',
      jsonb_build_object('withdrawal_id', new.id, 'route', v_route)
    );
  elsif new.status = 'refunded' then
    insert into public.user_notifications (user_id, title, message, type, data)
    values (
      v_profile_id,
      'Withdrawal Refunded',
      'Rs. ' || new.amount || ' from withdrawal ' || new.withdrawal_no || ' has been credited back to your wallet.',
      'withdrawal_refunded',
      jsonb_build_object('withdrawal_id', new.id, 'route', v_route)
    );
  end if;
  return new;
end;
$function$;

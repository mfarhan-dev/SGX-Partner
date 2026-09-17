-- 1. pg_net, needed to call the send-push Edge Function from a trigger.
create extension if not exists pg_net;

-- 2. Fire a real push the instant ANY row lands in user_notifications --
-- whether inserted by the triggers below, or by the separate staff admin
-- panel writing directly to this table (as the existing withdrawal_paid/
-- confirmed/refunded rows already do). Uses the public anon key -- the
-- same one already compiled into the Flutter app, safe to embed here.
create or replace function public.notify_push_on_user_notification()
returns trigger
language plpgsql
security definer
set search_path to ''
as $$
begin
  perform net.http_post(
    url := 'https://ghojtefwuzubqguqcbwc.supabase.co/functions/v1/send-push',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdob2p0ZWZ3dXp1YnFndXFjYndjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY3ODg5NjcsImV4cCI6MjEwMjM2NDk2N30.iOCXiFKblhD3so53-NuRrMwFShL0-O78qE-eH3xUNBQ'
    ),
    body := jsonb_build_object(
      'table', 'user_notifications',
      'record', jsonb_build_object(
        'id', new.id,
        'user_id', new.user_id,
        'title', new.title,
        'message', new.message,
        'type', new.type,
        'data', new.data
      )
    )
  );
  return new;
end;
$$;

drop trigger if exists trg_notify_push_on_user_notification on public.user_notifications;
create trigger trg_notify_push_on_user_notification
after insert on public.user_notifications
for each row execute function public.notify_push_on_user_notification();

-- 3. Withdrawal submitted -- request_withdrawal() only ever inserts; no
-- existing code notifies the partner their request went through.
create or replace function public.notify_withdrawal_submitted()
returns trigger
language plpgsql
security definer
set search_path to ''
as $$
declare
  v_profile_id uuid;
begin
  if new.mechanic_id is not null then
    select profile_id into v_profile_id from public.mechanics where id = new.mechanic_id;
  else
    select profile_id into v_profile_id from public.wholesalers where id = new.wholesaler_id;
  end if;

  if v_profile_id is not null then
    insert into public.user_notifications (user_id, title, message, type, data)
    values (
      v_profile_id,
      'Withdrawal Submitted',
      'Your withdrawal request ' || new.withdrawal_no || ' has been submitted.',
      'withdrawal_submitted',
      jsonb_build_object('withdrawal_id', new.id)
    );
  end if;
  return new;
end;
$$;

drop trigger if exists trg_notify_withdrawal_submitted on public.withdrawals;
create trigger trg_notify_withdrawal_submitted
after insert on public.withdrawals
for each row execute function public.notify_withdrawal_submitted();

-- 4. Withdrawal disputed / auto-confirmed -- both status transitions the
-- staff admin panel has no natural reason to notify about itself: disputed
-- is the partner's own action (dispute_withdrawal_received()), and
-- auto-confirmed is the scheduled auto_confirm_stale_withdrawals() job
-- firing with nobody on staff actively involved. Reuses whichever status
-- actually landed, regardless of which code path produced it.
create or replace function public.notify_withdrawal_status_change()
returns trigger
language plpgsql
security definer
set search_path to ''
as $$
declare
  v_profile_id uuid;
begin
  if new.status = old.status then
    return new;
  end if;
  if new.status not in ('disputed', 'auto_confirmed') then
    return new;
  end if;

  if new.mechanic_id is not null then
    select profile_id into v_profile_id from public.mechanics where id = new.mechanic_id;
  else
    select profile_id into v_profile_id from public.wholesalers where id = new.wholesaler_id;
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
      jsonb_build_object('withdrawal_id', new.id)
    );
  elsif new.status = 'auto_confirmed' then
    insert into public.user_notifications (user_id, title, message, type, data)
    values (
      v_profile_id,
      'Withdrawal Auto-Confirmed',
      'Withdrawal ' || new.withdrawal_no || ' was automatically marked as received after no response.',
      'withdrawal_auto_confirmed',
      jsonb_build_object('withdrawal_id', new.id)
    );
  end if;
  return new;
end;
$$;

drop trigger if exists trg_notify_withdrawal_status_change on public.withdrawals;
create trigger trg_notify_withdrawal_status_change
after update of status on public.withdrawals
for each row execute function public.notify_withdrawal_status_change();

-- 5. QR reward credited -- both the mechanic who scanned and the
-- wholesaler whose invoice it belonged to get their own reward-credited
-- notification the instant a scan is confirmed.
create or replace function public.notify_qr_reward_credited()
returns trigger
language plpgsql
security definer
set search_path to ''
as $$
declare
  v_mechanic_profile_id uuid;
  v_wholesaler_profile_id uuid;
  v_product_name text;
begin
  if new.status <> 'scanned' or old.status = 'scanned' then
    return new;
  end if;

  select name into v_product_name from public.products where id = new.product_id;

  if new.mechanic_id is not null then
    select profile_id into v_mechanic_profile_id from public.mechanics where id = new.mechanic_id;
    if v_mechanic_profile_id is not null then
      insert into public.user_notifications (user_id, title, message, type, data)
      values (
        v_mechanic_profile_id,
        'Reward Credited',
        'You earned Rs. ' || new.mechanic_reward_snapshot || coalesce(' for scanning ' || v_product_name, '') || '.',
        'qr_reward_credited',
        jsonb_build_object('qr_id', new.id)
      );
    end if;
  end if;

  if new.wholesaler_id is not null then
    select profile_id into v_wholesaler_profile_id from public.wholesalers where id = new.wholesaler_id;
    if v_wholesaler_profile_id is not null then
      insert into public.user_notifications (user_id, title, message, type, data)
      values (
        v_wholesaler_profile_id,
        'Reward Credited',
        'You earned Rs. ' || new.wholesaler_reward_snapshot || coalesce(' from a scan of ' || v_product_name, '') || '.',
        'qr_reward_credited',
        jsonb_build_object('qr_id', new.id)
      );
    end if;
  end if;

  return new;
end;
$$;

drop trigger if exists trg_notify_qr_reward_credited on public.qr_codes;
create trigger trg_notify_qr_reward_credited
after update of status on public.qr_codes
for each row execute function public.notify_qr_reward_credited();

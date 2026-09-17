-- Two real gaps confirmed against the live schema:
-- 1. Staff marking a withdrawal's payment as sent (status -> payment_sent)
--    fired no notification at all -- the partner had no way to know
--    without opening the app and checking.
-- 2. Every notification's `data` carried a raw id (qr_id/withdrawal_id)
--    but never a `route`, even though the client's PushMessage has
--    parsed `data.route`/`data.deep_link` since it was written -- the
--    field was simply never sent. Routes point to the same destination
--    the in-app bell already uses for each event (Activity, i.e.
--    /mechanic/wallet or /wholesaler/wallet), per the existing "no
--    separate Notifications screen" design decision -- a push and a
--    bell tap for the same event type should not land differently.

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
  if new.status not in ('disputed', 'auto_confirmed', 'payment_sent') then
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
  end if;
  return new;
end;
$function$;

create or replace function public.notify_withdrawal_submitted()
returns trigger
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_profile_id uuid;
  v_route text;
begin
  if new.mechanic_id is not null then
    select profile_id into v_profile_id from public.mechanics where id = new.mechanic_id;
    v_route := '/mechanic/wallet';
  else
    select profile_id into v_profile_id from public.wholesalers where id = new.wholesaler_id;
    v_route := '/wholesaler/wallet';
  end if;

  if v_profile_id is not null then
    insert into public.user_notifications (user_id, title, message, type, data)
    values (
      v_profile_id,
      'Withdrawal Submitted',
      'Your withdrawal request ' || new.withdrawal_no || ' has been submitted.',
      'withdrawal_submitted',
      jsonb_build_object('withdrawal_id', new.id, 'route', v_route)
    );
  end if;
  return new;
end;
$function$;

create or replace function public.notify_qr_reward_credited()
returns trigger
language plpgsql
security definer
set search_path to ''
as $function$
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
        jsonb_build_object('qr_id', new.id, 'route', '/mechanic/wallet')
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
        jsonb_build_object('qr_id', new.id, 'route', '/wholesaler/wallet')
      );
    end if;
  end if;

  return new;
end;
$function$;

-- New: a campaign becoming visible to partners (draft/scheduled -> active,
-- the exact transition get_active_campaigns() starts returning it on) now
-- notifies exactly the partners campaign_audiences actually targets --
-- mirroring seed_campaign_eligible_participants()'s own audience match
-- rather than reading its output, so this has no dependency on trigger
-- firing order within the same statement.
create or replace function public.notify_campaign_published()
returns trigger
language plpgsql
security definer
set search_path to ''
as $function$
begin
  if not (old.status in ('draft', 'scheduled') and new.status = 'active') then
    return new;
  end if;

  insert into public.user_notifications (user_id, title, message, type, data)
  select
    mechanic.profile_id,
    'New Campaign',
    new.title || ' is now live.',
    'campaign_published',
    jsonb_build_object('campaign_id', new.id, 'route', '/campaigns')
  from public.mechanics as mechanic
  where mechanic.is_active
    and mechanic.profile_id is not null
    and exists (
      select 1 from public.campaign_audiences target
      where target.campaign_id = new.id and target.audience = 'mechanic'
    );

  insert into public.user_notifications (user_id, title, message, type, data)
  select
    wholesaler.profile_id,
    'New Campaign',
    new.title || ' is now live.',
    'campaign_published',
    jsonb_build_object('campaign_id', new.id, 'route', '/campaigns')
  from public.wholesalers as wholesaler
  where wholesaler.is_active
    and wholesaler.profile_id is not null
    and exists (
      select 1 from public.campaign_audiences target
      where target.campaign_id = new.id and target.audience = 'wholesaler'
    );

  return new;
end;
$function$;

create trigger trg_notify_campaign_published
  after update of status on public.campaigns
  for each row
  when (old.status is distinct from new.status)
  execute function public.notify_campaign_published();

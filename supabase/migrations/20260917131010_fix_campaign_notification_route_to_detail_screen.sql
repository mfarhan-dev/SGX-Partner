-- '/campaigns' (the plain list screen) is unreachable from anywhere in
-- the app's own UI -- confirmed by grep across lib/: nothing pushes or
-- goes there. Campaigns are only ever shown via Home's own carousel,
-- and a card tap there goes straight to '/campaigns/:campaignId' (the
-- one real, tested destination). Route the notification to that same
-- specific campaign's detail page instead of the orphaned list screen.
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
    jsonb_build_object('campaign_id', new.id, 'route', '/campaigns/' || new.id::text)
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
    jsonb_build_object('campaign_id', new.id, 'route', '/campaigns/' || new.id::text)
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

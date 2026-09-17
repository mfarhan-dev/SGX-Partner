-- Campaigns/campaign_audiences/campaign-images were all staff-only --
-- a mechanic or wholesaler had zero visibility into any campaign, even
-- one actively running and targeted at their own role. This adds the
-- narrowest possible self-service surface: only currently ACTIVE
-- campaigns, only the ones this caller's own role is actually
-- targeted by, and only safe display fields (no staff-only lifecycle
-- timestamps, no other roles' targeting data).

-- Mirrors private.is_staff()'s style: SECURITY DEFINER so it can see
-- campaigns/campaign_audiences/profiles regardless of their own
-- staff-only RLS, used both by the RPC below and by the storage
-- policy on campaign-images.
create or replace function private.is_active_campaign_for_caller(p_campaign_id uuid)
returns boolean
language sql
stable
security definer
set search_path to ''
as $function$
  select exists (
    select 1
    from public.campaigns c
    join public.campaign_audiences ca on ca.campaign_id = c.id
    join public.profiles p on p.id = (select auth.uid())
    where c.id = p_campaign_id
      and c.status = 'active'
      and ca.audience = p.role
  );
$function$;

revoke all on function private.is_active_campaign_for_caller(uuid) from public;
revoke all on function private.is_active_campaign_for_caller(uuid) from anon;
grant execute on function private.is_active_campaign_for_caller(uuid) to authenticated;

create or replace function public.get_active_campaigns()
returns table(
  id uuid,
  title text,
  description text,
  prize_note text,
  start_date date,
  end_date date,
  image_storage_path text
)
language sql
stable
security definer
set search_path to ''
as $function$
  select c.id, c.title, c.description, c.prize_note, c.start_date, c.end_date, c.image_storage_path
  from public.campaigns c
  join public.campaign_audiences ca on ca.campaign_id = c.id
  join public.profiles p on p.id = (select auth.uid())
  where c.status = 'active'
    and ca.audience = p.role
  order by c.end_date asc nulls last, c.created_at desc;
$function$;

revoke all on function public.get_active_campaigns() from public;
revoke all on function public.get_active_campaigns() from anon;
grant execute on function public.get_active_campaigns() to authenticated;

create policy "partner can read own-audience active campaign images"
on storage.objects for select
to authenticated
using (
  bucket_id = 'campaign-images'
  and exists (
    select 1 from public.campaigns c
    where c.image_storage_path = storage.objects.name
      and private.is_active_campaign_for_caller(c.id)
  )
);

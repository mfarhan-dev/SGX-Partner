-- Bug in the previous migration: the storage policy did
-- `exists (select 1 from public.campaigns c where ...)` directly in
-- its own USING clause. That inner select is still subject to
-- campaigns' own RLS (staff-only SELECT) evaluated as the CALLING
-- user, not the function -- so for a mechanic/wholesaler it always
-- found zero rows and the "exists" was always false, regardless of
-- private.is_active_campaign_for_caller()'s result. The campaigns
-- lookup itself has to happen INSIDE a SECURITY DEFINER function to
-- actually bypass that RLS, not just the eligibility check.

drop policy if exists "partner can read own-audience active campaign images" on storage.objects;
drop function if exists private.is_active_campaign_for_caller(uuid);

create or replace function private.campaign_image_visible(p_name text)
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
    where c.image_storage_path = p_name
      and c.status = 'active'
      and ca.audience = p.role
  );
$function$;

revoke all on function private.campaign_image_visible(text) from public;
revoke all on function private.campaign_image_visible(text) from anon;
grant execute on function private.campaign_image_visible(text) to authenticated;

create policy "partner can read own-audience active campaign images"
on storage.objects for select
to authenticated
using (
  bucket_id = 'campaign-images'
  and private.campaign_image_visible(storage.objects.name)
);

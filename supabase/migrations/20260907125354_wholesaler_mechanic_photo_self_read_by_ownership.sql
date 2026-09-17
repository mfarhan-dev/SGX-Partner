-- The folder-prefix policies only cover photos uploaded *through the
-- app* going forward (<uid>/...). Photos staff uploaded via the CMS
-- before this feature existed use a flat filename with no folder at
-- all, so a wholesaler/mechanic could never read their own legacy
-- photo under the old policy. Replace the self-read policies with a
-- check against the row the caller actually owns: "is this the photo
-- path currently recorded on MY OWN wholesalers/mechanics row?" --
-- covers both new self-uploaded (<uid>/...) and old flat-named
-- legacy photos alike.

drop policy if exists "wholesaler can read own photo" on storage.objects;
create policy "wholesaler can read own photo"
on storage.objects for select
to authenticated
using (
  bucket_id = 'wholesaler-photos'
  and exists (
    select 1 from public.wholesalers w
    where w.profile_id = (select auth.uid())
      and w.photo_storage_path = storage.objects.name
  )
);

drop policy if exists "mechanic can read own photo" on storage.objects;
create policy "mechanic can read own photo"
on storage.objects for select
to authenticated
using (
  bucket_id = 'mechanic-photos'
  and exists (
    select 1 from public.mechanics m
    where m.profile_id = (select auth.uid())
      and m.photo_storage_path = storage.objects.name
  )
);

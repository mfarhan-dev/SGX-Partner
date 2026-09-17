-- ============================================================
-- wholesaler-photos storage bucket
--
-- The Add/Edit Wholesaler form captures a shop photo from the
-- device camera and currently keeps it as a base64 data URL in
-- component state. Persisting that string in Postgres would put
-- a multi-hundred-KB blob on every wholesaler row and drag it
-- into every list query; the photo columns on wholesalers hold a
-- storage object key instead.
--
-- Private bucket, like claim-receipts and unlike product-images:
-- a shop photo identifies a named trade partner and their
-- premises, so reads go through staff-only signed URLs rather
-- than a public CDN path.
-- ============================================================

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'wholesaler-photos',
  'wholesaler-photos',
  false,
  5242880,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do nothing;

create policy "staff can read wholesaler photos"
on storage.objects for select
to authenticated
using (bucket_id = 'wholesaler-photos' and (select private.is_staff()));

create policy "staff can upload wholesaler photos"
on storage.objects for insert
to authenticated
with check (bucket_id = 'wholesaler-photos' and (select private.is_staff()));

create policy "staff can update wholesaler photos"
on storage.objects for update
to authenticated
using (bucket_id = 'wholesaler-photos' and (select private.is_staff()))
with check (bucket_id = 'wholesaler-photos' and (select private.is_staff()));

create policy "staff can delete wholesaler photos"
on storage.objects for delete
to authenticated
using (bucket_id = 'wholesaler-photos' and (select private.is_staff()));

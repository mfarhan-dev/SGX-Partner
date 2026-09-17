insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'mechanic-photos',
  'mechanic-photos',
  false,
  5242880,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do nothing;

create policy "staff can read mechanic photos"
on storage.objects for select
to authenticated
using (bucket_id = 'mechanic-photos' and (select private.is_staff()));

create policy "staff can upload mechanic photos"
on storage.objects for insert
to authenticated
with check (bucket_id = 'mechanic-photos' and (select private.is_staff()));

create policy "staff can update mechanic photos"
on storage.objects for update
to authenticated
using (bucket_id = 'mechanic-photos' and (select private.is_staff()))
with check (bucket_id = 'mechanic-photos' and (select private.is_staff()));

create policy "staff can delete mechanic photos"
on storage.objects for delete
to authenticated
using (bucket_id = 'mechanic-photos' and (select private.is_staff()));

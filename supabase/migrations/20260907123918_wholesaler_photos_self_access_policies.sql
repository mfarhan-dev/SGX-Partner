create policy "wholesaler can read own photo"
on storage.objects for select
to authenticated
using (
  bucket_id = 'wholesaler-photos'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

create policy "wholesaler can upload own photo"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'wholesaler-photos'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

create policy "wholesaler can update own photo"
on storage.objects for update
to authenticated
using (
  bucket_id = 'wholesaler-photos'
  and (storage.foldername(name))[1] = (select auth.uid())::text
)
with check (
  bucket_id = 'wholesaler-photos'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

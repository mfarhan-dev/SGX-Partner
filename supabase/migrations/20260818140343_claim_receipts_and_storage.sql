-- ============================================================
-- Claim receipt upload
--
-- One optional receipt/photo per claim -- proof of what the
-- supplier's rep handed over or agreed to at settlement (or, for
-- Pending/Sent claims, proof of the defect itself). A single
-- nullable set of columns on claims is enough: this is not a
-- gallery like product_images, just one attachment per row.
--
-- Unlike product-images, this bucket is NOT public. Receipts can
-- carry settlement amounts and supplier names, so reads are
-- staff-only via signed URLs, same gate as the metadata columns.
-- ============================================================

alter table public.claims
  add column receipt_storage_path text
    check (receipt_storage_path is null or char_length(receipt_storage_path) between 1 and 500),
  add column receipt_file_size_bytes integer
    check (receipt_file_size_bytes is null or (receipt_file_size_bytes > 0 and receipt_file_size_bytes <= 5242880)),
  add column receipt_mime_type text
    check (receipt_mime_type is null or receipt_mime_type in ('image/jpeg', 'image/png', 'image/webp'));

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'claim-receipts',
  'claim-receipts',
  false,
  5242880,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do nothing;

create policy "staff can read claim receipts"
on storage.objects for select
to authenticated
using (bucket_id = 'claim-receipts' and (select private.is_staff()));

create policy "staff can upload claim receipts"
on storage.objects for insert
to authenticated
with check (bucket_id = 'claim-receipts' and (select private.is_staff()));

create policy "staff can update claim receipts"
on storage.objects for update
to authenticated
using (bucket_id = 'claim-receipts' and (select private.is_staff()))
with check (bucket_id = 'claim-receipts' and (select private.is_staff()));

create policy "staff can delete claim receipts"
on storage.objects for delete
to authenticated
using (bucket_id = 'claim-receipts' and (select private.is_staff()));

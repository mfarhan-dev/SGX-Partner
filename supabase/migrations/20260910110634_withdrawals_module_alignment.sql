-- Align withdrawals table with admin panel requirements and staff access.
-- Adds payment proof & transaction ref columns, staff RLS policies, and withdrawal-proofs storage bucket.
-- (Reconciliation: this content already exists live; registering it into tracked migration history.)

alter table public.withdrawals
  add column if not exists proof_storage_path text
    check (proof_storage_path is null or char_length(proof_storage_path) between 1 and 500),
  add column if not exists transaction_ref text
    check (transaction_ref is null or char_length(transaction_ref) <= 100);

drop policy if exists withdrawals_staff_select on public.withdrawals;
create policy withdrawals_staff_select on public.withdrawals
  for select
  to authenticated
  using ((select private.is_staff()));

drop policy if exists withdrawals_staff_update on public.withdrawals;
create policy withdrawals_staff_update on public.withdrawals
  for update
  to authenticated
  using ((select private.is_staff()))
  with check ((select private.is_staff()));

create index if not exists idx_withdrawals_status on public.withdrawals(status);
create index if not exists idx_withdrawals_requested_at on public.withdrawals(requested_at desc);
create index if not exists idx_withdrawals_mechanic on public.withdrawals(mechanic_id);
create index if not exists idx_withdrawals_wholesaler on public.withdrawals(wholesaler_id);

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'withdrawal-proofs',
  'withdrawal-proofs',
  false,
  5242880,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do nothing;

drop policy if exists "staff can read withdrawal proofs" on storage.objects;
create policy "staff can read withdrawal proofs"
on storage.objects for select
to authenticated
using (bucket_id = 'withdrawal-proofs' and (select private.is_staff()));

drop policy if exists "staff can upload withdrawal proofs" on storage.objects;
create policy "staff can upload withdrawal proofs"
on storage.objects for insert
to authenticated
with check (bucket_id = 'withdrawal-proofs' and (select private.is_staff()));

drop policy if exists "staff can update withdrawal proofs" on storage.objects;
create policy "staff can update withdrawal proofs"
on storage.objects for update
to authenticated
using (bucket_id = 'withdrawal-proofs' and (select private.is_staff()))
with check (bucket_id = 'withdrawal-proofs' and (select private.is_staff()));

drop policy if exists "staff can delete withdrawal proofs" on storage.objects;
create policy "staff can delete withdrawal proofs"
on storage.objects for delete
to authenticated
using (bucket_id = 'withdrawal-proofs' and (select private.is_staff()));

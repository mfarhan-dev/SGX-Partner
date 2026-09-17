drop policy "partner can read own withdrawal proof" on storage.objects;

-- Proof files are stored as "<withdrawal_id>/<filename>" -- matching by
-- that folder prefix (instead of withdrawals.proof_storage_path, which
-- only ever holds the LATEST payment's path and gets overwritten on a
-- re-pay) lets a partner read every proof ever uploaded for their own
-- withdrawal, not just whichever one happens to be current right now.
create policy "partner can read own withdrawal proofs" on storage.objects
  for select
  using (
    bucket_id = 'withdrawal-proofs'
    and exists (
      select 1 from public.withdrawals w
      where w.id::text = (storage.foldername(objects.name))[1]
        and (
          w.mechanic_id in (select id from public.mechanics where profile_id = (select auth.uid()))
          or w.wholesaler_id in (select id from public.wholesalers where profile_id = (select auth.uid()))
        )
    )
  );

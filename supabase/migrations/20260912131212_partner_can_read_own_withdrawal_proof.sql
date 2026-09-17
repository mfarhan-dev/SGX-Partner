
-- Mirrors the existing "mechanic can read own photo" / "wholesaler can
-- read own photo" pattern on mechanic-photos/wholesaler-photos: the
-- partner can read a withdrawal-proofs object only when it's the
-- exact proof_storage_path on one of their own withdrawals. Staff
-- keep their existing separate read policy untouched.
create policy "partner can read own withdrawal proof" on storage.objects
  for select
  using (
    bucket_id = 'withdrawal-proofs'
    and exists (
      select 1 from public.withdrawals w
      where w.proof_storage_path = objects.name
        and (
          w.mechanic_id in (select id from public.mechanics where profile_id = (select auth.uid()))
          or w.wholesaler_id in (select id from public.wholesalers where profile_id = (select auth.uid()))
        )
    )
  );

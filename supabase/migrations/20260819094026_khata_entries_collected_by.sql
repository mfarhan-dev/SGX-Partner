-- ============================================================
-- khata_entries.collected_by
--
-- Who physically took the money, which is not the same person as
-- created_by. A collector goes out on a Saturday and brings cash
-- back; a counter clerk records it on Monday. created_by is the
-- clerk, collected_by is the collector. Collapsing the two would
-- lose exactly the accountability this column exists for.
--
-- Nullable, because it only applies to payments: an opening
-- balance, an invoice, or a sales return has nobody collecting
-- anything. The check enforces that rather than leaving it to
-- the application to remember.
-- ============================================================

alter table public.khata_entries
  add column collected_by uuid references public.profiles(id) on delete set null;

alter table public.khata_entries
  add constraint khata_entries_collected_by_on_payment
    check (collected_by is null or entry_type = 'payment');

create index khata_entries_collected_by_idx
  on public.khata_entries (collected_by);

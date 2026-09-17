-- ============================================================
-- Drop wholesalers.profile_id
--
-- Added speculatively to link a wholesaler row to a future SGX
-- Partners login. Nothing reads or writes it: the column is empty,
-- no TypeScript references it, and the mobile auth model and role
-- enum are both still unsettled (see docs/TODO.md).
--
-- When the B2B app does need to connect a login to a wholesaler,
-- adding the column back is a one-line migration, and by then the
-- auth decisions will be settled enough to model it correctly.
-- ============================================================

drop index if exists public.wholesalers_profile_idx;

alter table public.wholesalers
  drop column if exists profile_id;

-- ============================================================
-- Re-add wholesalers.profile_id (dropped 20260819080539 pending a
-- settled mobile auth model) and add the equivalent on mechanics.
--
-- Set once the wholesaler/mechanic logs into SGX Partners for the
-- first time and their pre-created business record is matched by
-- phone and "claimed" (see claim_partner_profile()). Null until then.
-- ============================================================

alter table public.wholesalers
  add column profile_id uuid references public.profiles(id) on delete set null;

alter table public.mechanics
  add column profile_id uuid references public.profiles(id) on delete set null;

-- A profile can claim at most one business record of each kind.
create unique index wholesalers_profile_id_key on public.wholesalers (profile_id) where profile_id is not null;
create unique index mechanics_profile_id_key on public.mechanics (profile_id) where profile_id is not null;

create index wholesalers_profile_idx on public.wholesalers (profile_id);
create index mechanics_profile_idx on public.mechanics (profile_id);

-- Staff already have full select access; add self-access so the
-- logged-in wholesaler/mechanic can read their own claimed record
-- (their profile_id = their own auth.uid()).
create policy wholesalers_select_self on public.wholesalers
for select to authenticated
using (profile_id = (select auth.uid()));

create policy mechanics_select_self on public.mechanics
for select to authenticated
using (profile_id = (select auth.uid()));

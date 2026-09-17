
-- One saved account per provider per partner -- the app's own "Add a
-- payout account" list already hides a provider once it's saved; this
-- makes that a real guarantee instead of just a UI nicety.
create unique index payout_accounts_mechanic_provider_unique
  on public.payout_accounts (mechanic_id, provider)
  where mechanic_id is not null;

create unique index payout_accounts_wholesaler_provider_unique
  on public.payout_accounts (wholesaler_id, provider)
  where wholesaler_id is not null;

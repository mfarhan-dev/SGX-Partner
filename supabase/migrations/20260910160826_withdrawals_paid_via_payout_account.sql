-- Records which saved payout account the admin actually paid to for a given
-- withdrawal, distinct from `payout_account_id` (what the user originally
-- requested). Lets the admin fall back to a different saved account (e.g.
-- EasyPaisa is down, pay via JazzCash instead) without losing the record of
-- what was originally asked for.

alter table public.withdrawals
  add column if not exists paid_via_payout_account_id uuid
    references public.payout_accounts(id);

create index if not exists idx_withdrawals_paid_via_payout_account
  on public.withdrawals(paid_via_payout_account_id);

-- Expands payout_method from 3 fixed values to the real provider
-- catalog: 5 mobile wallets + 10 banks, matching lib/shared/withdrawals/domain/payout_provider.dart.
-- Each bank is its own provider id now -- no separate bank_name field,
-- since "which bank" and "which provider" are the same choice.
alter table public.mechanics drop constraint mechanics_payout_method_check;
alter table public.mechanics
  add constraint mechanics_payout_method_check
  check (payout_method is null or payout_method in (
    'easy_paisa', 'jazz_cash', 'sada_pay', 'naya_pay', 'u_paisa',
    'meezan_bank', 'hbl', 'ubl', 'mcb_bank', 'bank_alfalah',
    'allied_bank', 'askari_bank', 'faysal_bank', 'bank_al_habib', 'nbp'
  ));

alter table public.wholesalers drop constraint wholesalers_payout_method_check;
alter table public.wholesalers
  add constraint wholesalers_payout_method_check
  check (payout_method is null or payout_method in (
    'easy_paisa', 'jazz_cash', 'sada_pay', 'naya_pay', 'u_paisa',
    'meezan_bank', 'hbl', 'ubl', 'mcb_bank', 'bank_alfalah',
    'allied_bank', 'askari_bank', 'faysal_bank', 'bank_al_habib', 'nbp'
  ));

alter table public.withdrawals drop constraint withdrawals_method_check;
alter table public.withdrawals
  add constraint withdrawals_method_check
  check (method in (
    'easy_paisa', 'jazz_cash', 'sada_pay', 'naya_pay', 'u_paisa',
    'meezan_bank', 'hbl', 'ubl', 'mcb_bank', 'bank_alfalah',
    'allied_bank', 'askari_bank', 'faysal_bank', 'bank_al_habib', 'nbp'
  ));

comment on column public.mechanics.payout_method is
  'Provider id from the payout provider catalog (5 mobile wallets + 10 banks) -- see PayoutProvider.catalog in the Flutter app. Null means not configured yet.';
comment on column public.wholesalers.payout_method is
  'Provider id from the payout provider catalog (5 mobile wallets + 10 banks) -- see PayoutProvider.catalog in the Flutter app. Null means not configured yet.';

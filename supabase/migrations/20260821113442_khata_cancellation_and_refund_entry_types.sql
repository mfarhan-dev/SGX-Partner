-- Cancelling an invoice was being written as entry_type 'payment' (the only
-- credit-shaped type available) and a cash refund as 'invoice'. Both are
-- wrong: the ledger claimed a wholesaler paid on a day nothing was
-- collected, and getLastPaymentDates() - which powers the "Last Payment"
-- stat by querying entry_type = 'payment' - was therefore stamped by
-- cancellations. Two honest types instead.
alter table public.khata_entries
  drop constraint khata_entries_entry_type_check;

alter table public.khata_entries
  add constraint khata_entries_entry_type_check
  check (entry_type in (
    'opening_balance',
    'invoice',
    'payment',
    'sales_return',
    'invoice_cancelled',
    'cash_refund'
  ));

-- A refund is money physically handed back over the counter, so it has a
-- collector for the same reason a payment does. The old constraint allowed
-- collected_by only on 'payment'.
alter table public.khata_entries
  drop constraint khata_entries_collected_by_on_payment;

alter table public.khata_entries
  add constraint khata_entries_collected_by_on_payment
  check (collected_by is null or entry_type in ('payment', 'cash_refund'));

-- Relabel the rows already written under the old scheme. khata_entries is
-- append-only via khata_entries_no_update, so the guard is lifted for this
-- one statement and restored immediately. This corrects a *label* only -
-- no debit, credit or balance_after value is touched, and apply_khata_entry
-- is a BEFORE INSERT trigger so no balance is recomputed.
alter table public.khata_entries disable trigger khata_entries_no_update;

update public.khata_entries
set entry_type = 'invoice_cancelled'
where entry_type = 'payment'
  and note like 'Reversal for cancelled %';

update public.khata_entries
set entry_type = 'cash_refund'
where entry_type = 'invoice'
  and note like 'Cash refunded on cancellation of %';

alter table public.khata_entries enable trigger khata_entries_no_update;

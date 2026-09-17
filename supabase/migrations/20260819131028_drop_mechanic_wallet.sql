drop trigger if exists wallet_transactions_no_update on public.wallet_transactions;
drop function if exists public.block_wallet_transaction_mutation();
drop table if exists public.wallet_transactions;

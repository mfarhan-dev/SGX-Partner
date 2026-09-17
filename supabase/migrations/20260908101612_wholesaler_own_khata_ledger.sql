-- khata_entries was staff-only -- a wholesaler had zero visibility
-- into their own account ledger with SGX. Added the same narrow,
-- self-scoped RPC pattern as everywhere else: only this caller's own
-- wholesaler_id's rows, ordered by seq (the table's own strictly
-- increasing order, more reliable than created_at for tie-breaking
-- same-day entries).

create or replace function public.get_khata_ledger()
returns table(
  id uuid,
  entry_type text,
  entry_date date,
  reference text,
  note text,
  payment_method text,
  debit numeric,
  credit numeric,
  balance_after numeric
)
language sql
stable
security definer
set search_path to ''
as $function$
  select
    k.id, k.entry_type, k.entry_date, k.reference, k.note,
    k.payment_method, k.debit, k.credit, k.balance_after
  from public.khata_entries k
  join public.wholesalers w on w.id = k.wholesaler_id
  where w.profile_id = (select auth.uid())
  order by k.seq desc;
$function$;

revoke all on function public.get_khata_ledger() from public;
revoke all on function public.get_khata_ledger() from anon;
grant execute on function public.get_khata_ledger() to authenticated;

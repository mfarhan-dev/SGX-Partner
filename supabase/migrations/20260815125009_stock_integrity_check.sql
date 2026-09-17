-- ============================================================
-- Stock reconciliation.
--
-- products.stock is a cached rollup of the stock_adjustments
-- ledger, maintained by trigger. This function proves the two
-- still agree.
--
-- It is NOT a trigger: nothing calls it during normal stock
-- movement. Run it on demand, or on a schedule via Supabase Cron.
-- A healthy database returns zero rows.
-- ============================================================

create or replace function public.check_stock_integrity()
returns table (
  product_id uuid,
  product_name text,
  stored_stock integer,
  ledger_stock integer,
  difference integer
)
language sql
security invoker
stable
set search_path = ''
as $$
  select
    p.id,
    p.name,
    p.stock,
    coalesce(sum(sa.quantity_change), 0)::integer,
    (p.stock - coalesce(sum(sa.quantity_change), 0))::integer
  from public.products p
  left join public.stock_adjustments sa on sa.product_id = p.id
  where p.deleted_at is null
  group by p.id, p.name, p.stock
  having p.stock <> coalesce(sum(sa.quantity_change), 0);
$$;

comment on function public.check_stock_integrity() is
  'Returns products whose cached stock disagrees with their stock_adjustments ledger. Empty result means healthy. Run on demand or via Supabase Cron; not a trigger.';

-- Staff-only: this reads product names and stock levels.
revoke execute on function public.check_stock_integrity() from public, anon;
grant execute on function public.check_stock_integrity() to authenticated;

create or replace function public.get_wholesaler_qr_progress()
returns table (
  invoice_line_id uuid,
  invoice_number text,
  product_name text,
  total integer,
  scanned integer,
  earned integer
)
language sql
stable
security definer
set search_path to ''
as $$
  select
    il.id as invoice_line_id,
    i.invoice_number,
    il.product_name_snapshot as product_name,
    il.qr_count as total,
    count(q.id) filter (where q.status = 'scanned')::integer as scanned,
    coalesce(sum(q.wholesaler_reward_snapshot) filter (where q.status = 'scanned'), 0)::integer as earned
  from public.invoice_lines il
  join public.invoices i on i.id = il.invoice_id
  left join public.qr_codes q on q.invoice_line_id = il.id
  where i.wholesaler_id = (
    select w.id from public.wholesalers w where w.profile_id = (select auth.uid())
  )
  and i.status = 'dispatched'
  and il.qr_count > 0
  group by il.id, i.invoice_number, il.product_name_snapshot, il.qr_count, i.dispatched_at
  order by i.dispatched_at desc nulls last;
$$;

revoke all on function public.get_wholesaler_qr_progress() from public;
revoke all on function public.get_wholesaler_qr_progress() from anon;
grant execute on function public.get_wholesaler_qr_progress() to authenticated;

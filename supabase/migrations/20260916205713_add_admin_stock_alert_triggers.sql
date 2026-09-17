-- Stock alerts for staff -- fires once when a product's stock CROSSES
-- into the low (<=10) or out-of-stock (=0) band, not on every subsequent
-- decrement while it stays there (which would otherwise spam the shared
-- inbox on every sale of an already-low item). Out-of-stock is strictly
-- worse than low, so a big single decrement straight to 0 only fires
-- stock_out, not both.
create or replace function public.notify_admin_stock_alert()
returns trigger
language plpgsql
security definer
set search_path to ''
as $$
begin
  if new.stock = old.stock then
    return new;
  end if;

  if new.stock = 0 and old.stock <> 0 then
    insert into public.admin_notifications (type, title, description, link_to)
    values (
      'stock_out',
      new.name || ' is out of stock',
      'Stock has reached 0 units. Add stock to resume sales.',
      '/dashboard/products/' || new.id
    );
  elsif new.stock > 0 and new.stock <= 10 and old.stock > 10 then
    insert into public.admin_notifications (type, title, description, link_to)
    values (
      'stock_low',
      new.name || ' is running low',
      'Only ' || new.stock || ' units remaining. Consider restocking soon.',
      '/dashboard/products/' || new.id
    );
  end if;

  return new;
end;
$$;

drop trigger if exists trg_notify_admin_stock_alert on public.products;
create trigger trg_notify_admin_stock_alert
after update of stock on public.products
for each row execute function public.notify_admin_stock_alert();

revoke all on function public.notify_admin_stock_alert() from public, anon, authenticated;

-- Staff-facing notification inbox -- a shared feed for admin/manager/
-- counter_staff, distinct from the partner-facing user_notifications
-- table (personal to one mechanic/wholesaler, phone-push-backed). This
-- one is a web-dashboard inbox: any active staff member sees every row,
-- there is no per-staff read state yet (matches the admin panel's own
-- Module_12 doc, which lists per-user read receipts as future work).
create table public.admin_notifications (
  id uuid primary key default gen_random_uuid(),
  type text not null check (type in (
    'order_placed', 'order_failed',
    'withdrawal_new', 'withdrawal_disputed',
    'stock_low', 'stock_out'
  )),
  title text not null,
  description text not null,
  link_to text not null,
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.admin_notifications enable row level security;

create policy admin_notifications_select_staff
  on public.admin_notifications for select
  using (private.is_staff());

create policy admin_notifications_update_staff
  on public.admin_notifications for update
  using (private.is_staff());

-- No insert/delete policy for any client role -- rows are only ever
-- created by the SECURITY DEFINER triggers below, and never deleted
-- from the app.

-- Withdrawal submitted -- staff needs to know a new request is waiting
-- the moment request_withdrawal() creates it (status is always
-- 'pending' at insert).
create or replace function public.notify_admin_withdrawal_new()
returns trigger
language plpgsql
security definer
set search_path to ''
as $$
declare
  v_partner_name text;
begin
  if new.mechanic_id is not null then
    select full_name into v_partner_name from public.mechanics where id = new.mechanic_id;
  else
    select coalesce(shop_name, owner_name) into v_partner_name from public.wholesalers where id = new.wholesaler_id;
  end if;

  insert into public.admin_notifications (type, title, description, link_to)
  values (
    'withdrawal_new',
    'New Withdrawal Request',
    coalesce(v_partner_name, 'A partner') || ' requested a withdrawal of Rs. ' || new.amount || ' (' || new.withdrawal_no || ').',
    '/dashboard/withdrawals/' || new.id
  );
  return new;
end;
$$;

drop trigger if exists trg_notify_admin_withdrawal_new on public.withdrawals;
create trigger trg_notify_admin_withdrawal_new
after insert on public.withdrawals
for each row execute function public.notify_admin_withdrawal_new();

-- Withdrawal disputed -- a partner-initiated dispute (dispute_withdrawal_
-- received()) needs staff attention regardless of which client caused
-- the status transition.
create or replace function public.notify_admin_withdrawal_disputed()
returns trigger
language plpgsql
security definer
set search_path to ''
as $$
declare
  v_partner_name text;
begin
  if new.status = old.status or new.status <> 'disputed' then
    return new;
  end if;

  if new.mechanic_id is not null then
    select full_name into v_partner_name from public.mechanics where id = new.mechanic_id;
  else
    select coalesce(shop_name, owner_name) into v_partner_name from public.wholesalers where id = new.wholesaler_id;
  end if;

  insert into public.admin_notifications (type, title, description, link_to)
  values (
    'withdrawal_disputed',
    'Withdrawal Disputed',
    coalesce(v_partner_name, 'A partner') || ' disputed withdrawal ' || new.withdrawal_no || coalesce(': ' || new.dispute_reason, '') || '.',
    '/dashboard/withdrawals/' || new.id
  );
  return new;
end;
$$;

drop trigger if exists trg_notify_admin_withdrawal_disputed on public.withdrawals;
create trigger trg_notify_admin_withdrawal_disputed
after update of status on public.withdrawals
for each row execute function public.notify_admin_withdrawal_disputed();

revoke all on function public.notify_admin_withdrawal_new() from public, anon, authenticated;
revoke all on function public.notify_admin_withdrawal_disputed() from public, anon, authenticated;

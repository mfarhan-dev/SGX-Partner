-- mechanics had no reward balance column at all. wholesalers already
-- has points_balance but it's currently unguarded -- anyone with
-- UPDATE access to the row could silently corrupt it. Both get the
-- exact same protection khata_balance already has: no direct edits
-- except through one trusted, session-flag-authorized path.

alter table public.mechanics
  add column points_balance integer not null default 0
  constraint mechanics_points_balance_check check (points_balance >= 0);

create or replace function public.guard_mechanic_points_balance()
returns trigger
language plpgsql
set search_path to ''
as $function$
begin
  if new.points_balance is distinct from old.points_balance
     and coalesce(current_setting('sgx.points_sync', true), 'off') <> 'on' then
    raise exception 'mechanics.points_balance is derived. It can only change when a QR code is scanned.'
      using errcode = '0A000';
  end if;
  return new;
end;
$function$;

create trigger mechanics_points_balance_guard
  before update on public.mechanics
  for each row execute function public.guard_mechanic_points_balance();

create or replace function public.guard_wholesaler_points_balance()
returns trigger
language plpgsql
set search_path to ''
as $function$
begin
  if new.points_balance is distinct from old.points_balance
     and coalesce(current_setting('sgx.points_sync', true), 'off') <> 'on' then
    raise exception 'wholesalers.points_balance is derived. It can only change when a QR code is scanned.'
      using errcode = '0A000';
  end if;
  return new;
end;
$function$;

create trigger wholesalers_points_balance_guard
  before update on public.wholesalers
  for each row execute function public.guard_wholesaler_points_balance();

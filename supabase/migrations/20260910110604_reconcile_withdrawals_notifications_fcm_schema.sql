-- Reconciliation migration: these objects were already applied directly to
-- production (outside tracked migration history) during withdrawals/notifications
-- work. Written idempotently on purpose -- it registers the existing state into
-- schema_migrations without changing live behavior.

-- 1. Additional withdrawal columns
alter table public.withdrawals
  add column if not exists wallet_available_before integer,
  add column if not exists wallet_pending_before integer,
  add column if not exists bank_name text,
  add column if not exists admin_note text,
  add column if not exists resolution_note text,
  add column if not exists refund_note text,
  add column if not exists disputed_at timestamptz,
  add column if not exists auto_confirmed_at timestamptz,
  add column if not exists refunded_at timestamptz;

-- 2. In-app user notifications table
create table if not exists public.user_notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  title text not null,
  message text not null,
  type text not null,
  data jsonb,
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.user_notifications enable row level security;

drop policy if exists "Users can view their own notifications" on public.user_notifications;
create policy "Users can view their own notifications" on public.user_notifications
  for select
  to authenticated
  using (auth.uid() = user_id);

drop policy if exists "Users can update their own notifications" on public.user_notifications;
create policy "Users can update their own notifications" on public.user_notifications
  for update
  to authenticated
  using (auth.uid() = user_id);

drop policy if exists "Staff can manage all notifications" on public.user_notifications;
create policy "Staff can manage all notifications" on public.user_notifications
  for all
  to authenticated
  using (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid()
        and profiles.role in ('admin', 'manager', 'counter_staff')
    )
  );

-- 3. Auto-confirm stale "payment_sent" withdrawals (scheduled job target)
create or replace function public.auto_confirm_stale_withdrawals()
returns void
language plpgsql
as $$
begin
  update public.withdrawals
  set
    status = 'auto_confirmed',
    auto_confirmed_at = now(),
    updated_at = now()
  where
    status = 'payment_sent'
    and payment_sent_at < (now() - interval '3 days');
end;
$$;

-- 4. FCM token storage on profiles, for push notification delivery
alter table public.profiles
  add column if not exists fcm_token text;

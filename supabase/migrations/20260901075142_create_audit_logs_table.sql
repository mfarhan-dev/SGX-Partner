-- Module 15 Audit Logs. Append-only record of who did what, when, and what
-- changed, across the 9 real modules wired so far (Auth, Products, Stock/
-- Claims, Schemes, Wholesalers, Mechanics, Invoices, QR Codes, Expenses).
-- Settings, System/Scheduled Jobs, auto-expense cross-linking, print events,
-- Withdrawals, Orders, and Customers have no real write path yet - see
-- docs/Module_15_Audit_Logs_GAPS.md. Rows are never updated or deleted after
-- insert - no update/delete policy exists below, and that omission IS the
-- enforcement.

create sequence if not exists public.audit_log_number_seq;

create table public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  event_no text not null unique
    default ('AUD-' || lpad(nextval('public.audit_log_number_seq')::text, 5, '0')),

  created_at timestamptz not null default now(),

  -- Who. actor_profile_id is the integrity anchor (immutable, survives a
  -- rename); actor_name/actor_role are the frozen point-in-time display
  -- copy - never join these live, that would defeat the audit trail.
  actor_profile_id uuid references public.profiles(id) on delete set null,
  actor_name text not null,
  actor_role text,

  module text not null check (
    module in (
      'Auth', 'Products', 'Schemes', 'Wholesalers', 'Mechanics', 'Customers',
      'Invoices', 'Orders', 'QR Codes', 'Withdrawals', 'Expenses', 'Reports',
      'Settings', 'System'
    )
  ),
  action text not null,
  target text,

  summary text not null,
  outcome text not null check (outcome in ('success', 'failed')),

  -- Always 'admin_panel' until the B2B/Customer apps or a job runner exist.
  source text not null default 'admin_panel' check (
    source in (
      'admin_panel', 'auth_service', 'b2b_app', 'customer_app',
      'edge_function', 'scheduled_job', 'system'
    )
  ),

  ip_address text,
  session_id text,
  note text check (note is null or char_length(note) <= 500),

  -- Changed fields only, per module - never a full record dump. A null
  -- `before` is expected on create-type events.
  before_snapshot jsonb,
  after_snapshot jsonb
);

comment on table public.audit_logs is
  'Append-only audit trail. No update or delete policy exists on this table by design - a row is permanent from the moment it is written.';

create index audit_logs_created_at_idx on public.audit_logs (created_at desc);
create index audit_logs_module_idx on public.audit_logs (module, created_at desc);
create index audit_logs_outcome_idx on public.audit_logs (outcome, created_at desc);
create index audit_logs_actor_profile_id_idx on public.audit_logs (actor_profile_id);
create index audit_logs_actor_name_idx on public.audit_logs (actor_name);
create index audit_logs_target_idx on public.audit_logs (target);

alter table public.audit_logs enable row level security;

create policy audit_logs_select_admin on public.audit_logs
  for select using ((select private.is_admin()));

create policy audit_logs_insert_staff on public.audit_logs
  for insert with check ((select private.is_staff()));

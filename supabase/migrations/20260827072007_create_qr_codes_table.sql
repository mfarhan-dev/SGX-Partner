-- Module 10 QR Codes. Fills in the table invoice_lines.qr_count was
-- always meant to back (see its comment on the invoices migration) - one
-- row per reward-eligible unit on an invoice line, frozen at generation
-- time (Snapshot Principle, same as invoice_lines' own *_snapshot columns:
-- changing a product/wholesaler/scheme later must never alter an already-
-- generated QR).
--
-- Real HMAC signing and the full `v1.<qr_id>.<product_id>.<signature>`
-- payload belong to the future mechanic-scan backend, which does not
-- exist yet (out of scope for this module per spec §"What This Module
-- Must Not Do" / "Do not wire the mechanic scan API"). `payload` is kept
-- nullable for that reason - the Module 10 spec's own future-schema
-- section (§10.1) marks it `not null unique`, but nothing can sign it yet.
-- Tighten it once the scan backend is built.
create table public.qr_codes (
  id uuid primary key default gen_random_uuid(),

  qr_id text not null unique,
  payload_version text not null default 'v1',
  payload text unique,

  invoice_id uuid not null references public.invoices(id) on delete cascade,
  invoice_line_id uuid not null references public.invoice_lines(id) on delete cascade,
  product_id uuid not null references public.products(id),
  wholesaler_id uuid references public.wholesalers(id),

  status text not null default 'generated'
    check (status in ('generated', 'active', 'scanned', 'void')),

  -- Snapshot columns, frozen at generation - mirrors invoice_lines'
  -- product_name_snapshot/brand_snapshot pattern exactly, plus the
  -- wholesaler fields invoice_lines doesn't need (invoices already joins
  -- to a live wholesalers row; QR records must not).
  product_name_snapshot text not null,
  product_code_snapshot text not null,
  brand_snapshot text,
  wholesaler_shop_snapshot text,
  wholesaler_owner_snapshot text,
  wholesaler_phone_snapshot text,
  wholesaler_area_snapshot text,

  -- Reward split snapshot from Module 8 Schemes at the moment the invoice
  -- was issued. UI label is "Seller Reward" (Module 10 spec §9.3); column
  -- stays wholesaler_reward_snapshot to match invoice_lines' naming.
  mechanic_reward_snapshot integer not null default 0 check (mechanic_reward_snapshot >= 0),
  wholesaler_reward_snapshot integer not null default 0 check (wholesaler_reward_snapshot >= 0),
  conversion_rate_snapshot numeric(8, 2) not null default 1,

  mechanic_id uuid references public.mechanics(id),
  active_at timestamptz,
  scanned_at timestamptz,
  expires_at timestamptz,
  created_at timestamptz not null default now()
);

comment on table public.qr_codes is
  'One row per reward-eligible unit on an invoice line, generated when the invoice is issued. Read-only in the admin panel (Module 10 v1) - status only ever changes via the invoice lifecycle (dispatch/cancel) or, in future, the mechanic scan backend.';

create index qr_codes_status_created_idx on public.qr_codes (status, created_at desc);
create index qr_codes_invoice_idx on public.qr_codes (invoice_id);
create index qr_codes_product_idx on public.qr_codes (product_id);
create index qr_codes_wholesaler_idx on public.qr_codes (wholesaler_id);
create index qr_codes_scanned_at_idx on public.qr_codes (scanned_at desc);

alter table public.qr_codes enable row level security;

create policy qr_codes_select_staff on public.qr_codes
  for select using ((select private.is_staff()));
create policy qr_codes_insert_staff on public.qr_codes
  for insert with check ((select private.is_staff()));
create policy qr_codes_update_staff on public.qr_codes
  for update using ((select private.is_staff())) with check ((select private.is_staff()));

-- Mirrors enforce_invoice_status_transition() (invoice_lifecycle_guards
-- migration): generated -> active|void, active -> scanned; scanned and
-- void are terminal. Stamps active_at/scanned_at so the app never has to
-- remember to set it on every write path. The admin panel only ever
-- drives generated->active (dispatch) and generated->void (cancel); the
-- active->scanned edge is reserved for the future mechanic scan backend.
create or replace function public.enforce_qr_code_status_transition()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.status = old.status then
    return new;
  end if;

  if old.status = 'generated' and new.status in ('active', 'void') then
    -- allowed
  elsif old.status = 'active' and new.status = 'scanned' then
    -- allowed
  else
    raise exception 'Invalid QR code status transition: % -> %', old.status, new.status
      using errcode = '22023';
  end if;

  if new.status = 'active' and new.active_at is null then
    new.active_at := now();
  elsif new.status = 'scanned' and new.scanned_at is null then
    new.scanned_at := now();
  end if;

  return new;
end;
$$;

create trigger qr_codes_status_transition
  before update on public.qr_codes
  for each row execute function public.enforce_qr_code_status_transition();

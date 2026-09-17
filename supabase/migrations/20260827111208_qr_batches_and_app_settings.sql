alter table public.qr_codes
  alter column invoice_id drop not null,
  alter column invoice_line_id drop not null;

alter table public.qr_codes
  add column source text not null default 'invoice' check (source in ('invoice', 'batch'));

alter table public.qr_codes
  add constraint qr_codes_invoice_fields_consistent
  check ((invoice_id is null) = (invoice_line_id is null));

alter table public.qr_codes
  add constraint qr_codes_source_matches_invoice
  check (
    (source = 'invoice' and invoice_id is not null) or
    (source = 'batch' and invoice_id is null)
  );

comment on column public.qr_codes.source is
  'invoice: generated when a Wholesaler-type invoice was issued (invoice_id/invoice_line_id set). batch: generated directly for shelf stock via the QR Codes page, no invoice involved.';

create table public.app_settings (
  id boolean primary key default true,
  default_qr_wholesaler_id uuid references public.wholesalers(id),
  updated_at timestamptz not null default now(),
  updated_by uuid references public.profiles(id),
  constraint app_settings_singleton check (id)
);

comment on table public.app_settings is
  'Single-row global settings. Seeded with its one row below - the app only ever has to handle a null value inside it, never a missing row.';

insert into public.app_settings (id) values (true);

alter table public.app_settings enable row level security;

create policy app_settings_select_staff on public.app_settings
  for select using ((select private.is_staff()));
create policy app_settings_update_staff on public.app_settings
  for update using ((select private.is_staff())) with check ((select private.is_staff()));

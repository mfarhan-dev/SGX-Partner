alter table public.app_settings
  rename column default_qr_wholesaler_id to default_wholesaler_id;

alter table public.app_settings
  add column min_withdrawal_amount integer not null default 100
    check (min_withdrawal_amount between 1 and 100000),
  add column withdrawal_processing_time text not null default '48 hours'
    check (char_length(withdrawal_processing_time) between 3 and 50),
  add column auto_confirm_window_days integer not null default 7
    check (auto_confirm_window_days between 1 and 30),
  add column admin_whatsapp_number text not null default '+923001234567'
    check (admin_whatsapp_number ~ '^(\+92[0-9]{10}|03[0-9]{9})$');

comment on table public.app_settings is
  'Single-row global settings (Settings > General, plus the QR batch default wholesaler). Seeded with its one row - the app only ever has to handle a null value inside it, never a missing row.';

-- Module 10 QR Codes now exists (qr_codes table) and generates one real
-- row per qr_count unit at invoice issue - the "dummy/preview" caveat
-- this comment carried no longer applies.
comment on table public.invoice_lines is
  'Snapshot line items for an invoice. qr_count is how many qr_codes rows were generated for this line (one per reward-eligible unit) - see qr_codes.invoice_line_id.';

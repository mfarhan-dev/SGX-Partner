alter table public.qr_codes
  drop column payload,
  drop column payload_version,
  drop column conversion_rate_snapshot,
  drop column product_name_snapshot,
  drop column product_code_snapshot,
  drop column brand_snapshot,
  drop column wholesaler_shop_snapshot,
  drop column wholesaler_owner_snapshot,
  drop column wholesaler_phone_snapshot,
  drop column wholesaler_area_snapshot;

comment on table public.qr_codes is
  'One QR sticker: from a Wholesaler invoice line (source=invoice) or generated ahead of any sale for shelf stock (source=batch). Only the reward split is snapshotted - everything else is joined live. Read-only in the admin panel; status changes come from the invoice lifecycle or, in future, the mechanic scan backend.';

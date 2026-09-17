-- stock_adjustments.invoice_id and khata_entries.invoice_id already existed
-- (added ahead of time, same way sales_return_id is already on both) but
-- had no FK constraint since public.invoices did not exist yet.
alter table public.stock_adjustments
  add constraint stock_adjustments_invoice_id_fkey
  foreign key (invoice_id) references public.invoices(id);

alter table public.khata_entries
  add constraint khata_entries_invoice_id_fkey
  foreign key (invoice_id) references public.invoices(id);

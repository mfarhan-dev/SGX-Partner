-- Bug fix: batch-generated QR codes could never leave 'generated'.
--
-- Only two code paths ever advance a QR's status - markInvoiceDispatched()
-- (generated -> active) and cancelInvoice() (generated -> void) - and both
-- scope their update with `.eq("invoice_id", invoice.id)`. Batch rows have
-- invoice_id = null, so neither could ever match them. Every batch QR ever
-- generated was frozen at 'generated' with no path out.
--
-- The right resting state for a batch QR is 'active', not 'generated'.
-- 'generated' means "printed, but the goods have not left the building
-- yet" - it exists so an invoice's stickers can't be scanned before
-- dispatch. A batch sticker has no dispatch step at all: it is stuck onto
-- stock already sitting on the shelf, ready to hand to whoever buys the
-- unit. It is scannable the moment it is printed.
--
-- generateQrBatch() now inserts these as 'active' directly. This backfills
-- the rows created before that fix. The status-transition trigger allows
-- generated -> active and stamps active_at itself, so a plain update is
-- enough here.
update public.qr_codes
set status = 'active'
where source = 'batch'
  and status = 'generated';

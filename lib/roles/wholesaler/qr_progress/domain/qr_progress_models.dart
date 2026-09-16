/// One invoice line's QR-code batch progress, from
/// get_wholesaler_qr_progress(). That RPC only returns lines that
/// actually carry QR codes (`qr_count > 0`) on a dispatched invoice --
/// QR codes only go live once an invoice is dispatched, so an
/// `invoiced` or `cancelled` invoice's lines never appear here.
class QrProgressBatch {
  const QrProgressBatch({
    required this.invoiceLineId,
    required this.invoiceNumber,
    required this.productName,
    required this.total,
    required this.scanned,
    required this.earned,
  });

  final String invoiceLineId;
  final String invoiceNumber;
  final String productName;

  /// Total QR codes printed for this line (`invoice_lines.qr_count`).
  final int total;

  /// How many of those have actually been scanned by a mechanic.
  final int scanned;

  /// Rs. earned by this wholesaler so far from this batch's scanned
  /// codes -- the sum of each scanned code's own reward snapshot, not
  /// an estimate.
  final int earned;

  int get remaining => total - scanned;

  double get progress => total == 0 ? 0 : scanned / total;
}

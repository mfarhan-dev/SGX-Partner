class QrProgressSummary {
  const QrProgressSummary({required this.totalQr, required this.scannedQr});

  final int totalQr;
  final int scannedQr;
}

class QrProgressItem {
  const QrProgressItem({
    required this.campaignName,
    required this.scanned,
    required this.total,
  });

  final String campaignName;
  final int scanned;
  final int total;
}

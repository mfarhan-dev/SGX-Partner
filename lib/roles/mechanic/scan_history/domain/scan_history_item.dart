import '../../../../shared/models/money_amount.dart';

class ScanHistoryItem {
  const ScanHistoryItem({
    required this.id,
    required this.productName,
    required this.reward,
    required this.scannedAt,
  });

  final String id;
  final String productName;
  final MoneyAmount reward;
  final DateTime scannedAt;
}

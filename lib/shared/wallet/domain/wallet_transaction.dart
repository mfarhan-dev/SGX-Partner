import '../../../shared/models/money_amount.dart';

class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.createdAt,
  });

  final String id;
  final String title;
  final MoneyAmount amount;
  final DateTime createdAt;
}

import '../../../shared/models/money_amount.dart';

class WalletSummary {
  const WalletSummary({
    required this.availableBalance,
    required this.pendingWithdrawal,
    required this.lifetimeEarned,
  });

  final MoneyAmount availableBalance;
  final MoneyAmount pendingWithdrawal;
  final MoneyAmount lifetimeEarned;
}

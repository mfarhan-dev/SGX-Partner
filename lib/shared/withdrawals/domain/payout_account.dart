import 'payout_provider.dart';

/// One saved payout channel belonging to the signed-in partner. A
/// partner can save several of these (a wallet and a bank account,
/// two different wallet numbers, ...) -- see payout_accounts table.
/// There's no "default" flag -- accounts are always shown in the
/// order they were added (see payoutAccountsProvider's `order by
/// created_at`), and request_withdrawal() falls back to the
/// first-added one when a withdrawal doesn't name a specific account.
class PayoutAccount {
  const PayoutAccount({
    required this.id,
    required this.provider,
    required this.accountTitle,
    required this.accountNumber,
  });

  factory PayoutAccount.fromRow(Map<String, dynamic> row) {
    return PayoutAccount(
      id: row['id'] as String,
      provider: PayoutProvider.byId(row['provider'] as String),
      accountTitle: row['account_title'] as String,
      accountNumber: row['account_number'] as String,
    );
  }

  final String id;
  final PayoutProvider provider;
  final String accountTitle;
  final String accountNumber;
}

import 'wallet_summary.dart';
import 'wallet_transaction.dart';

abstract interface class WalletRepository {
  Future<WalletSummary> loadSummary();

  Future<List<WalletTransaction>> listTransactions();
}

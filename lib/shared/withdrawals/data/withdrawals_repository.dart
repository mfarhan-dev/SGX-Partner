import '../domain/payout_account.dart';
import '../domain/payout_provider.dart';
import '../domain/withdrawal.dart';

abstract interface class WithdrawalsRepository {
  Future<List<Withdrawal>> listWithdrawals();

  Future<Withdrawal> getWithdrawal(String withdrawalId);

  /// Pays out to [payoutAccountId] when given, otherwise to whichever
  /// saved account was added first -- request_withdrawal() snapshots
  /// the chosen account's provider/title/number onto the new row
  /// server-side. Fails with a clear error if the partner has no
  /// payout account saved yet at all.
  Future<Withdrawal> createWithdrawal({
    required int amountRupees,
    String? payoutAccountId,
  });

  Future<Withdrawal> confirmReceived(String withdrawalId);

  Future<Withdrawal> disputeReceived(String withdrawalId, String reason);

  /// Rs. minimum a partner is allowed to request in one withdrawal --
  /// from app_settings.min_withdrawal_amount, via get_withdrawal_settings()
  /// since app_settings itself is staff-only readable.
  Future<int> getMinWithdrawalAmount();

  /// Every payout account this partner has saved, in the order they
  /// were added (oldest first) -- see payoutAccountsProvider, which is
  /// what everywhere in the app should actually read from.
  Future<List<PayoutAccount>> listPayoutAccounts();

  /// Adds a new saved payout account, appended after whatever's
  /// already saved.
  Future<PayoutAccount> addPayoutAccount({
    required PayoutProvider provider,
    required String accountTitle,
    required String accountNumber,
  });

  /// Edits an existing account's title/number in place. The provider
  /// itself can't be changed -- add a new account for that instead.
  Future<PayoutAccount> updatePayoutAccount({
    required String accountId,
    required String accountTitle,
    required String accountNumber,
  });

  /// Deletes a saved account outright.
  Future<void> deletePayoutAccount(String accountId);
}

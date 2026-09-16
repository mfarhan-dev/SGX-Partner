import '../domain/payout_account.dart';
import '../domain/payout_provider.dart';
import '../domain/withdrawal.dart';
import '../domain/withdrawal_dispute_event.dart';
import '../domain/withdrawal_payment_event.dart';

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

  /// Signed, time-limited URL for a withdrawal's payment-proof
  /// screenshot -- pass [storagePath] straight from
  /// Withdrawal.proofStoragePath. Returns null if signing fails (e.g.
  /// the file was since deleted); never throws, since a missing
  /// screenshot shouldn't take down the whole detail screen.
  Future<String?> getProofImageUrl(String storagePath);

  /// Every time SGX marked [withdrawalId] paid, oldest first -- one row
  /// normally, more than one only when a dispute got re-paid. The
  /// `withdrawals` row itself only keeps the latest payment's
  /// timestamp/proof (a re-pay overwrites both), so this is the only
  /// place to see an earlier payment's own screenshot once a re-pay has
  /// happened. Backed by get_withdrawal_payment_events(), a
  /// partner-scoped read into `audit_logs` (otherwise staff-only).
  Future<List<WithdrawalPaymentEvent>> getPaymentEvents(String withdrawalId);

  /// Every time this partner disputed [withdrawalId], oldest first --
  /// one row normally, more than one only when a re-paid withdrawal got
  /// disputed again. The `withdrawals` row itself only keeps the latest
  /// dispute's reason/timestamp (a second dispute overwrites both), so
  /// this is the only place to see an earlier dispute's own reason once
  /// it's happened more than once. Backed by
  /// get_withdrawal_dispute_events(), a partner-scoped read into
  /// `audit_logs` (otherwise staff-only) -- mirrors [getPaymentEvents]
  /// exactly.
  Future<List<WithdrawalDisputeEvent>> getDisputeEvents(String withdrawalId);

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

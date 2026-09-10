import '../domain/withdrawal.dart';
import '../domain/withdrawal_method.dart';

abstract interface class WithdrawalsRepository {
  Future<List<Withdrawal>> listWithdrawals();

  Future<Withdrawal> getWithdrawal(String withdrawalId);

  /// Uses whatever payout method is currently saved for this partner
  /// (set via [setPayoutMethod]) -- request_withdrawal() snapshots it
  /// onto the new row server-side, so nothing about *how* to pay is
  /// collected here anymore.
  Future<Withdrawal> createWithdrawal({required int amountRupees});

  Future<Withdrawal> confirmReceived(String withdrawalId);

  Future<Withdrawal> disputeReceived(String withdrawalId, String reason);

  /// Rs. minimum a partner is allowed to request in one withdrawal --
  /// from app_settings.min_withdrawal_amount, via get_withdrawal_settings()
  /// since app_settings itself is staff-only readable.
  Future<int> getMinWithdrawalAmount();

  /// Saves this partner's payout method for all future withdrawals.
  /// Every method needs real account details -- the RPC itself
  /// rejects an incomplete request.
  Future<void> setPayoutMethod({
    required WithdrawalMethod method,
    required String accountTitle,
    required String accountNumber,
  });
}

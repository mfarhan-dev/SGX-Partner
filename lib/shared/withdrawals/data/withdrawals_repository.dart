import '../domain/withdrawal.dart';
import '../domain/withdrawal_method.dart';

abstract interface class WithdrawalsRepository {
  Future<List<Withdrawal>> listWithdrawals();

  Future<Withdrawal> getWithdrawal(String withdrawalId);

  Future<Withdrawal> createWithdrawal({
    required int amountRupees,
    required WithdrawalMethod method,
    required String accountTitle,
    required String accountNumber,
  });

  Future<Withdrawal> confirmReceived(String withdrawalId);

  Future<Withdrawal> disputeReceived(String withdrawalId, String reason);

  /// Rs. minimum a partner is allowed to request in one withdrawal --
  /// from app_settings.min_withdrawal_amount, via get_withdrawal_settings()
  /// since app_settings itself is staff-only readable.
  Future<int> getMinWithdrawalAmount();
}

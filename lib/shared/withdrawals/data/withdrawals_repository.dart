import '../domain/withdrawal.dart';
import '../domain/withdrawal_method.dart';

abstract interface class WithdrawalsRepository {
  Future<List<Withdrawal>> listWithdrawals();

  Future<Withdrawal> getWithdrawal(String withdrawalId);

  Future<Withdrawal> createWithdrawal({
    required int amountCents,
    required WithdrawalMethod method,
  });
}

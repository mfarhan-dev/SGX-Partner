import '../../../shared/models/money_amount.dart';
import 'withdrawal_method.dart';
import 'withdrawal_status.dart';

class Withdrawal {
  const Withdrawal({
    required this.id,
    required this.amount,
    required this.method,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final MoneyAmount amount;
  final WithdrawalMethod method;
  final WithdrawalStatus status;
  final DateTime createdAt;
}

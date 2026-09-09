import '../../../shared/models/money_amount.dart';
import 'withdrawal_method.dart';
import 'withdrawal_status.dart';

class Withdrawal {
  const Withdrawal({
    required this.id,
    required this.withdrawalNo,
    required this.amount,
    required this.method,
    required this.status,
    required this.accountTitle,
    required this.accountNumber,
    required this.requestedAt,
    this.disputeReason,
    this.paymentSentAt,
    this.confirmedAt,
  });

  /// Reads one row exactly as returned by the `withdrawals` table /
  /// request_withdrawal() RPC -- amount is whole rupees on the wire,
  /// same convention as mechanics.points_balance / wholesalers.points_balance.
  factory Withdrawal.fromRow(Map<String, dynamic> row) {
    return Withdrawal(
      id: row['id'] as String,
      withdrawalNo: row['withdrawal_no'] as String,
      amount: MoneyAmount(cents: (row['amount'] as num).toInt() * 100),
      method: WithdrawalMethod.fromDb(row['method'] as String),
      status: WithdrawalStatus.fromDb(row['status'] as String),
      accountTitle: row['account_title'] as String,
      accountNumber: row['account_number'] as String,
      disputeReason: row['dispute_reason'] as String?,
      requestedAt: DateTime.parse(row['requested_at'] as String),
      paymentSentAt: row['payment_sent_at'] == null
          ? null
          : DateTime.parse(row['payment_sent_at'] as String),
      confirmedAt: row['confirmed_at'] == null
          ? null
          : DateTime.parse(row['confirmed_at'] as String),
    );
  }

  final String id;
  final String withdrawalNo;
  final MoneyAmount amount;
  final WithdrawalMethod method;
  final WithdrawalStatus status;
  final String accountTitle;
  final String accountNumber;
  final String? disputeReason;
  final DateTime requestedAt;
  final DateTime? paymentSentAt;
  final DateTime? confirmedAt;
}

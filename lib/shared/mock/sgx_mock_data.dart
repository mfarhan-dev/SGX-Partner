import '../models/money_amount.dart';

class MockWithdrawal {
  const MockWithdrawal({
    required this.id,
    required this.amount,
    required this.method,
    required this.date,
    required this.status,
    required this.note,
  });

  final String id;
  final MoneyAmount amount;
  final String method;
  final String date;
  final String status;
  final String note;
}

const mockWithdrawals = [
  MockWithdrawal(
    id: 'wd-001',
    amount: MoneyAmount(cents: 500000),
    method: 'JazzCash',
    date: 'Today',
    status: 'Payment Sent',
    note: 'Please confirm after checking your balance.',
  ),
  MockWithdrawal(
    id: 'wd-002',
    amount: MoneyAmount(cents: 250000),
    method: 'EasyPaisa',
    date: '20 Jul 2026',
    status: 'Confirmed',
    note: 'Payment received and closed.',
  ),
  MockWithdrawal(
    id: 'wd-003',
    amount: MoneyAmount(cents: 420000),
    method: 'Bank Transfer',
    date: '18 Jul 2026',
    status: 'Disputed',
    note: 'SGX is reviewing this payment problem.',
  ),
];

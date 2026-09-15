import 'package:flutter/material.dart';

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

class MockQrProgress {
  const MockQrProgress({
    required this.productName,
    required this.reference,
    required this.scanned,
    required this.total,
    required this.earned,
    required this.icon,
  });

  final String productName;
  final String reference;
  final int scanned;
  final int total;
  final MoneyAmount earned;
  final IconData icon;

  int get remaining => total - scanned;

  double get progress => total == 0 ? 0 : scanned / total;
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

const mockQrProgress = [
  MockQrProgress(
    productName: 'Shell Advance AX7 10W-40',
    reference: 'INV-0058',
    scanned: 148,
    total: 200,
    earned: MoneyAmount(cents: 177600),
    icon: Icons.oil_barrel_outlined,
  ),
  MockQrProgress(
    productName: 'NGK Spark Plug CR7HSA',
    reference: 'INV-0061',
    scanned: 96,
    total: 120,
    earned: MoneyAmount(cents: 96000),
    icon: Icons.bolt_outlined,
  ),
  MockQrProgress(
    productName: 'DID Chain Kit 428H',
    reference: 'INV-0064',
    scanned: 242,
    total: 400,
    earned: MoneyAmount(cents: 290400),
    icon: Icons.link_outlined,
  ),
];

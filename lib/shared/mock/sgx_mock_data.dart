import 'package:flutter/material.dart';

import '../models/money_amount.dart';

class MockTransaction {
  const MockTransaction({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.icon,
    required this.tone,
    this.status,
  });

  final String title;
  final String subtitle;
  final MoneyAmount amount;
  final IconData icon;
  final Color tone;
  final String? status;
}

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

class MockScan {
  const MockScan({
    required this.productName,
    required this.time,
    required this.shopName,
    required this.reward,
    required this.icon,
  });

  final String productName;
  final String time;
  final String shopName;
  final MoneyAmount reward;
  final IconData icon;
}

const mechanicTransactions = [
  MockTransaction(
    title: 'QR reward added',
    subtitle: 'Shell Advance AX7 · Today',
    amount: MoneyAmount(cents: 1500),
    icon: Icons.add_circle_outline,
    tone: Color(0xFF138A43),
    status: 'Confirmed',
  ),
  MockTransaction(
    title: 'Withdrawal requested',
    subtitle: 'JazzCash · Today',
    amount: MoneyAmount(cents: -150000),
    icon: Icons.schedule_outlined,
    tone: Color(0xFFC78300),
    status: 'Pending',
  ),
  MockTransaction(
    title: 'Payment sent',
    subtitle: 'EasyPaisa · Yesterday',
    amount: MoneyAmount(cents: -250000),
    icon: Icons.send_outlined,
    tone: Color(0xFF253765),
    status: 'Confirm now',
  ),
];

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

const mockScans = [
  MockScan(
    productName: 'Shell Advance AX7 10W-40',
    time: 'Today · 10:24 AM',
    shopName: 'Farhan Motor Parts',
    reward: MoneyAmount(cents: 1500),
    icon: Icons.oil_barrel_outlined,
  ),
  MockScan(
    productName: 'NGK Spark Plug CR7HSA',
    time: 'Today · 9:10 AM',
    shopName: 'Bilal Auto Store',
    reward: MoneyAmount(cents: 800),
    icon: Icons.bolt_outlined,
  ),
  MockScan(
    productName: 'DID Chain Kit 428H',
    time: 'Yesterday · 6:42 PM',
    shopName: 'Shah Motors',
    reward: MoneyAmount(cents: 2000),
    icon: Icons.link_outlined,
  ),
];

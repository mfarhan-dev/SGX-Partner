import 'package:flutter/material.dart';

import '../models/money_amount.dart';

class MockProduct {
  const MockProduct({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.code,
    required this.icon,
    required this.description,
    this.detailLine = '',
  });

  final String id;
  final String name;
  final String brand;
  final String category;
  final String code;
  final IconData icon;
  final String description;
  final String detailLine;
}

class MockCampaign {
  const MockCampaign({
    required this.id,
    required this.title,
    required this.description,
    required this.dateWindow,
    required this.reward,
    required this.icon,
    required this.tone,
  });

  final String id;
  final String title;
  final String description;
  final String dateWindow;
  final String reward;
  final IconData icon;
  final Color tone;
}

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

const mockProducts = [
  MockProduct(
    id: 'shell-ax7',
    name: 'Shell Advance AX7 10W-40',
    brand: 'Shell',
    category: 'Engine Oil',
    code: 'SGX-OIL-AX7',
    icon: Icons.oil_barrel_outlined,
    detailLine: 'VOLUME 1 Litre · GRADE 10W-40 SL',
    description:
        'Premium motorcycle engine oil for daily-use bikes. Browse-only B2B catalog item.',
  ),
  MockProduct(
    id: 'ngk-plug',
    name: 'NGK Spark Plug CR7HSA',
    brand: 'NGK',
    category: 'Spark Plugs',
    code: 'SGX-SP-CR7',
    icon: Icons.bolt_outlined,
    detailLine: 'TYPE Spark Plug · FIT Universal',
    description:
        'Reliable spark plug used across common motorcycle models in Pakistan.',
  ),
  MockProduct(
    id: 'kn-filter',
    name: 'K&N Performance Air Filter',
    brand: 'K&N',
    category: 'Filters',
    code: 'SGX-FLT-KN1',
    icon: Icons.filter_alt_outlined,
    detailLine: 'TYPE Air Filter · SERIES Performance',
    description:
        'Reusable-style filter reference for design and mock catalog browsing.',
  ),
  MockProduct(
    id: 'did-chain',
    name: 'DID Chain Kit 428H',
    brand: 'DID',
    category: 'Chains',
    code: 'SGX-CH-428',
    icon: Icons.link_outlined,
    detailLine: 'SIZE 428H · TYPE Chain Kit',
    description:
        'Durable chain kit mock item. Pricing and stock are intentionally hidden.',
  ),
  MockProduct(
    id: 'ceat-tyre',
    name: 'CEAT Milaze Motorcycle Tyre',
    brand: 'CEAT',
    category: 'Tires',
    code: 'SGX-TYR-CEAT',
    icon: Icons.trip_origin_outlined,
    detailLine: 'TYPE Tyre · USE Daily commute',
    description:
        'Common motorcycle tyre reference for product catalog layout testing.',
  ),
  MockProduct(
    id: 'osaka-battery',
    name: 'Osaka Dry Battery 12V',
    brand: 'Osaka',
    category: 'Battery',
    code: 'SGX-BAT-12V',
    icon: Icons.battery_charging_full_outlined,
    detailLine: 'POWER 12V · TYPE Dry Battery',
    description:
        'Battery catalog item for B2B browsing. No ordering action appears in app.',
  ),
];

const mockCampaigns = [
  MockCampaign(
    id: 'shell-double',
    title: 'Double reward on Shell products',
    description: 'Scan eligible Shell product QRs and earn extra reward.',
    dateWindow: '20 Jul - 31 Jul 2026',
    reward: 'Double reward on every Shell product',
    icon: Icons.local_fire_department_outlined,
    tone: Color(0xFF0F766E),
  ),
  MockCampaign(
    id: 'filter-bonus',
    title: '+10% on filter sales',
    description: 'Bonus on confirmed filter QR activity during campaign.',
    dateWindow: '18 Jul - 28 Jul 2026',
    reward: '+10% on filter sales',
    icon: Icons.redeem_outlined,
    tone: Color(0xFF1E3A8A),
  ),
];

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

const wholesalerTransactions = [
  MockTransaction(
    title: 'QR reward added',
    subtitle: 'Shell Advance AX7 · 2 mins ago',
    amount: MoneyAmount(cents: 1200),
    icon: Icons.add_circle_outline,
    tone: Color(0xFF138A43),
    status: 'Confirmed',
  ),
  MockTransaction(
    title: 'Payment sent',
    subtitle: 'JazzCash · Today',
    amount: MoneyAmount(cents: -500000),
    icon: Icons.send_outlined,
    tone: Color(0xFF253765),
    status: 'Confirm now',
  ),
  MockTransaction(
    title: 'Money returned to wallet',
    subtitle: 'Refunded withdrawal · 20 Jul',
    amount: MoneyAmount(cents: 250000),
    icon: Icons.currency_exchange_outlined,
    tone: Color(0xFF138A43),
    status: 'Refunded',
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

import 'package:flutter/material.dart';

import '../../../../shared/models/money_amount.dart';
import '../../../../shared/widgets/money_text.dart';

class TransactionRow extends StatelessWidget {
  const TransactionRow({super.key, required this.title, required this.amount});

  final String title;
  final MoneyAmount amount;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: MoneyText(amount: amount),
    );
  }
}

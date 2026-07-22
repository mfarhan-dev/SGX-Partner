import 'package:flutter/material.dart';

import '../../../../shared/models/money_amount.dart';
import '../../../../shared/widgets/money_text.dart';

class WithdrawalCard extends StatelessWidget {
  const WithdrawalCard({
    super.key,
    required this.title,
    required this.amount,
    required this.status,
    this.onTap,
  });

  final String title;
  final MoneyAmount amount;
  final String status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(status),
        trailing: MoneyText(amount: amount),
        onTap: onTap,
      ),
    );
  }
}

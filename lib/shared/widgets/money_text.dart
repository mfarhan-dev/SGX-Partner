import 'package:flutter/material.dart';

import '../../core/utils/money_formatter.dart';
import '../models/money_amount.dart';

class MoneyText extends StatelessWidget {
  const MoneyText({super.key, required this.amount, this.style});

  final MoneyAmount amount;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text(MoneyFormatter.format(amount), style: style);
  }
}

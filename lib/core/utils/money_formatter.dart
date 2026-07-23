import 'package:intl/intl.dart';

import '../../shared/models/money_amount.dart';

class MoneyFormatter {
  const MoneyFormatter._();

  static String format(MoneyAmount amount) {
    final formatter = NumberFormat.currency(
      name: amount.currencyCode,
      symbol: 'Rs. ',
      decimalDigits: 0,
    );
    return formatter.format(amount.majorUnits);
  }
}

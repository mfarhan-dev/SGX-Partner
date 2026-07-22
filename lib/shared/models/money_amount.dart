class MoneyAmount {
  const MoneyAmount({required this.cents, this.currencyCode = 'PKR'});

  final int cents;
  final String currencyCode;

  double get majorUnits => cents / 100;
}

enum WithdrawalMethod {
  easyPaisa,
  jazzCash,
  bankTransfer,
  cashCollection;

  /// Parses the `withdrawals.method` text column exactly as its check
  /// constraint allows.
  factory WithdrawalMethod.fromDb(String value) => switch (value) {
    'easy_paisa' => easyPaisa,
    'jazz_cash' => jazzCash,
    'bank_transfer' => bankTransfer,
    'cash_collection' => cashCollection,
    _ => throw ArgumentError('Unknown withdrawal method: $value'),
  };

  /// The exact text request_withdrawal() expects for p_method.
  String get dbValue => switch (this) {
    easyPaisa => 'easy_paisa',
    jazzCash => 'jazz_cash',
    bankTransfer => 'bank_transfer',
    cashCollection => 'cash_collection',
  };

  String get label => switch (this) {
    easyPaisa => 'EasyPaisa',
    jazzCash => 'JazzCash',
    bankTransfer => 'Bank transfer',
    cashCollection => 'Cash collection from SGX',
  };

  String get accountFieldLabel => switch (this) {
    bankTransfer => 'Account number / IBAN *',
    cashCollection => 'Mobile Number *',
    _ => 'Mobile Number *',
  };
}

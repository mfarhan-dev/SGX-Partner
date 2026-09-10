enum WithdrawalMethod {
  easyPaisa,
  jazzCash,
  bankTransfer;

  /// Parses the `withdrawals.method` / `mechanics.payout_method` /
  /// `wholesalers.payout_method` text columns exactly as their check
  /// constraints allow. Cash collection from SGX was removed as an
  /// option -- there was no way for staff to reconcile it in the
  /// admin panel -- so every method here needs real account details.
  factory WithdrawalMethod.fromDb(String value) => switch (value) {
    'easy_paisa' => easyPaisa,
    'jazz_cash' => jazzCash,
    'bank_transfer' => bankTransfer,
    _ => throw ArgumentError('Unknown withdrawal method: $value'),
  };

  /// The exact text request_withdrawal()/set_payout_method() expect.
  String get dbValue => switch (this) {
    easyPaisa => 'easy_paisa',
    jazzCash => 'jazz_cash',
    bankTransfer => 'bank_transfer',
  };

  String get label => switch (this) {
    easyPaisa => 'EasyPaisa',
    jazzCash => 'JazzCash',
    bankTransfer => 'Bank transfer',
  };

  String get accountFieldLabel => switch (this) {
    bankTransfer => 'Account number / IBAN *',
    _ => 'Mobile Number *',
  };
}

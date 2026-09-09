enum WithdrawalStatus {
  pending,
  paymentSent,
  confirmed,
  disputed,
  autoConfirmed,
  refunded;

  /// Parses the `withdrawals.status` text column exactly as the guard
  /// trigger constrains it (see enforce_withdrawal_status_transition()).
  factory WithdrawalStatus.fromDb(String value) => switch (value) {
    'pending' => pending,
    'payment_sent' => paymentSent,
    'confirmed' => confirmed,
    'disputed' => disputed,
    'auto_confirmed' => autoConfirmed,
    'refunded' => refunded,
    _ => throw ArgumentError('Unknown withdrawal status: $value'),
  };

  String get label => switch (this) {
    pending => 'Pending',
    paymentSent => 'Payment Sent',
    confirmed => 'Confirmed',
    disputed => 'Disputed',
    autoConfirmed => 'Auto-confirmed',
    refunded => 'Refunded',
  };

  /// True once nothing can change this withdrawal further -- matches
  /// the guard trigger's terminal states exactly.
  bool get isTerminal =>
      this == confirmed || this == autoConfirmed || this == refunded;
}

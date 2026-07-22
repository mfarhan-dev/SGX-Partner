enum WithdrawalStatus {
  pending,
  paymentSent,
  confirmed,
  disputed,
  autoConfirmed,
  refunded;

  String get label => switch (this) {
    pending => 'Pending',
    paymentSent => 'Payment Sent',
    confirmed => 'Confirmed',
    disputed => 'Disputed',
    autoConfirmed => 'Auto-confirmed',
    refunded => 'Refunded',
  };
}

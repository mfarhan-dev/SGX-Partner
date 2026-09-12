/// One "SGX marked this withdrawal paid" moment, straight from
/// `audit_logs` via `get_withdrawal_payment_events()`. There is
/// normally exactly one of these per withdrawal; a second (or third)
/// one exists only when a dispute got re-paid -- see
/// [WithdrawalsRepository.getPaymentEvents]'s own doc comment for why
/// this can't come from the `withdrawals` row itself.
class WithdrawalPaymentEvent {
  const WithdrawalPaymentEvent({
    required this.paidAt,
    required this.proofStoragePath,
  });

  factory WithdrawalPaymentEvent.fromRow(Map<String, dynamic> row) {
    return WithdrawalPaymentEvent(
      paidAt: DateTime.parse(row['created_at'] as String),
      proofStoragePath: row['proof_storage_path'] as String?,
    );
  }

  final DateTime paidAt;

  /// Raw storage path into `withdrawal-proofs`, same shape as
  /// Withdrawal.proofStoragePath -- resolve with
  /// WithdrawalsRepository.getProofImageUrl / withdrawalProofUrlProvider.
  final String? proofStoragePath;
}

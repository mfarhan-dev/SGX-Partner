/// One "partner disputed this withdrawal" moment, straight from
/// `audit_logs` via `get_withdrawal_dispute_events()`. There is
/// normally exactly one of these per withdrawal; a second (or third)
/// one exists only when a re-paid withdrawal got disputed again -- see
/// [WithdrawalsRepository.getDisputeEvents]'s own doc comment for why
/// this can't come from the `withdrawals` row itself.
class WithdrawalDisputeEvent {
  const WithdrawalDisputeEvent({
    required this.disputedAt,
    required this.reason,
  });

  factory WithdrawalDisputeEvent.fromRow(Map<String, dynamic> row) {
    return WithdrawalDisputeEvent(
      disputedAt: DateTime.parse(row['created_at'] as String),
      reason: row['reason'] as String?,
    );
  }

  final DateTime disputedAt;
  final String? reason;
}

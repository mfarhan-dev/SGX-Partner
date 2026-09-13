/// One row in the mechanic Wallet screen's activity feed, from
/// get_mechanic_wallet_activity(). That RPC unions two real sources --
/// confirmed QR-scan rewards (`qr_codes`) and withdrawal lifecycle
/// events unpivoted off `withdrawals`' own timestamp columns -- and
/// already returns them newest-first, so no client-side merging or
/// sorting is needed here.
///
/// A single withdrawal can appear as up to four separate rows here
/// (requested / payment sent / confirmed-or-disputed-or-auto-confirmed
/// / refunded) as it progresses -- see the RPC's own comment for
/// exactly which transitions produce a row. This screen only shows a
/// one-line summary per row; the full timeline (with proof screenshots
/// and re-pay history) stays exclusively on the existing Withdrawal
/// Detail screen, reached by tapping through via [withdrawalId].
enum WalletEntryType {
  qrReward,
  withdrawalRequested,
  paymentSent,
  withdrawalConfirmed,
  withdrawalAutoConfirmed,
  withdrawalDisputed,
  withdrawalRefunded;

  factory WalletEntryType.fromDb(String value) => switch (value) {
    'qr_reward' => qrReward,
    'withdrawal_requested' => withdrawalRequested,
    'payment_sent' => paymentSent,
    'withdrawal_confirmed' => withdrawalConfirmed,
    'withdrawal_auto_confirmed' => withdrawalAutoConfirmed,
    'withdrawal_disputed' => withdrawalDisputed,
    'withdrawal_refunded' => withdrawalRefunded,
    _ => throw ArgumentError('Unknown wallet entry type: $value'),
  };
}

class WalletActivityEntry {
  const WalletActivityEntry({
    required this.id,
    required this.type,
    required this.occurredAt,
    required this.amount,
    required this.withdrawalId,
    required this.reference,
    required this.note,
  });

  final String id;
  final WalletEntryType type;
  final DateTime occurredAt;

  /// Signed Rs.; null for an event that carries no balance change of
  /// its own (payment sent / confirmed / disputed -- the balance
  /// already moved at "requested", or moves later at "refunded").
  final int? amount;

  /// Null for a QR reward row; the withdrawal's id for every
  /// withdrawal-lifecycle row, so a tap can push straight to its
  /// existing Detail screen.
  final String? withdrawalId;

  /// The scanned QR's own id for a reward row, or the withdrawal's
  /// human-readable number (e.g. "WD-0015") for a withdrawal row.
  final String reference;

  /// Product name for a reward row, dispute reason for a disputed row,
  /// refund note for a refunded row -- null otherwise.
  final String? note;

  bool get isWithdrawalEvent => withdrawalId != null;
}

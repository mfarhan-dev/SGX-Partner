enum ScanFailureReason {
  invalid,
  alreadyScanned,
  expired,
  inactiveAccount,
  network,
}

class ScanResult {
  const ScanResult.success({required this.message, required this.rewardAmount})
    : failureReason = null,
      claimedByName = null,
      claimedByWorkshop = null,
      claimedAt = null,
      claimedByYou = false;

  const ScanResult.failure({
    required this.message,
    required this.failureReason,
    this.claimedByName,
    this.claimedByWorkshop,
    this.claimedAt,
    this.claimedByYou = false,
  }) : rewardAmount = null;

  final String message;
  final ScanFailureReason? failureReason;

  /// Rs. credited by this scan -- only set on success, straight from
  /// scan_qr_code()'s own `reward` column, so the UI never has to
  /// re-derive it by parsing [message].
  final int? rewardAmount;

  /// Set only for [ScanFailureReason.alreadyScanned] -- who already
  /// claimed this code, straight from scan_qr_code()'s own
  /// `scanned_by_name`/`scanned_by_workshop`/`scanned_at` columns.
  /// Deliberately name + workshop only, never a phone number or photo:
  /// enough for a mechanic to see a false "I never got paid" claim is
  /// already settled, without handing out another mechanic's contact
  /// details, or opening up their profile photo to anyone who happens
  /// to scan their already-used sticker.
  final String? claimedByName;
  final String? claimedByWorkshop;
  final DateTime? claimedAt;

  /// True when the mechanic re-scanning this code is the exact same
  /// one who already claimed it -- straight from scan_qr_code()'s own
  /// `scanned_by_you` column (compared server-side by mechanic id, not
  /// by name, so two same-named mechanics can never be confused). The
  /// UI shows a plain "you already scanned this" instead of a name
  /// card in that case.
  final bool claimedByYou;

  bool get isSuccess => failureReason == null;
}

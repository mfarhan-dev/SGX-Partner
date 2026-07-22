enum ScanFailureReason {
  invalid,
  alreadyScanned,
  expired,
  inactiveAccount,
  network,
}

class ScanResult {
  const ScanResult.success({required this.message}) : failureReason = null;

  const ScanResult.failure({
    required this.message,
    required this.failureReason,
  });

  final String message;
  final ScanFailureReason? failureReason;

  bool get isSuccess => failureReason == null;
}

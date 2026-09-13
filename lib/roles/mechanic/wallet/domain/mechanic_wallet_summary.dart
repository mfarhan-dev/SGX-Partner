/// The mechanic Wallet screen's balance card, via
/// get_mechanic_wallet_summary(). `available` and `pending` are the
/// same server-authoritative numbers Home already derives (points_balance
/// itself, and the sum of every non-terminal withdrawal) -- `lifetimeEarned`
/// is new: the real, never-decreasing sum of every confirmed QR-scan
/// reward this mechanic has ever received, computed straight from
/// `qr_codes`, not a copy of `available` the way Home's own "Lifetime
/// Earned" figure still is (see handoff.md gap #5 -- still open there,
/// partially closed here).
class MechanicWalletSummary {
  const MechanicWalletSummary({
    required this.available,
    required this.pending,
    required this.lifetimeEarned,
  });

  final int available;
  final int pending;
  final int lifetimeEarned;

  static const zero = MechanicWalletSummary(
    available: 0,
    pending: 0,
    lifetimeEarned: 0,
  );
}

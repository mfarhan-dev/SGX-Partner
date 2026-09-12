/// Every Remote Config parameter the app reads, with the value it falls
/// back to when Firebase has never been reached.
///
/// Two rules for anything added here:
///
/// 1. **The default must describe today's shipped behaviour.** A fresh
///    install on a dead network uses these values, and a partner in a
///    workshop with no signal must get a working app, not a disabled
///    one. That's why every kill switch defaults to "on" and
///    maintenance mode defaults to "off".
/// 2. **Don't duplicate Supabase.** Anything row-shaped, per-partner, or
///    already behind an RPC (the support WhatsApp number, withdrawal
///    minimums, campaign content) belongs in Postgres. Remote Config is
///    for app-wide switches we want to flip without shipping a build.
/// 3. **Only add a key the app can actually act on.** A
///    `min_supported_build` force-update key was dropped for exactly this
///    reason: enforcing it means reading the running build number, which
///    needs a dependency this project doesn't have. A key nobody can
///    honour is worse than no key — someone will eventually set it and
///    expect something to happen.
class RemoteConfigKeys {
  const RemoteConfigKeys._();

  /// Hard stop. When true the app shows [maintenanceMessage] instead of
  /// letting the partner in — for a backend migration window, say.
  static const maintenanceMode = 'maintenance_mode';

  /// What to show while [maintenanceMode] is on. Kept separate so the
  /// reason can be edited without touching the switch.
  static const maintenanceMessage = 'maintenance_message';

  /// Feature kill switches, for taking one flow down without pulling the
  /// whole app. Each one guards a flow that moves money or writes
  /// irreversible rows, which is exactly where a remote off-switch earns
  /// its keep.
  static const qrScanningEnabled = 'qr_scanning_enabled';
  static const withdrawalsEnabled = 'withdrawals_enabled';

  static const defaults = <String, Object>{
    maintenanceMode: false,
    maintenanceMessage:
        'SGX Partners is briefly down for maintenance. Please try again in a few minutes.',
    qrScanningEnabled: true,
    withdrawalsEnabled: true,
  };
}

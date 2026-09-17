import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper over [SharedPreferences] -- the app's only on-device,
/// per-install persistence. Everything else in this app lives in
/// Supabase; this is only for UI preferences that must survive an app
/// restart without a server round trip (e.g. dark/light mode) and
/// have no reason to sync across a partner's devices. Anything that
/// should follow the partner (their name, their photo) belongs on
/// `profiles`, not here.
///
/// [initialize] is awaited once in `bootstrap()`, before `runApp()`,
/// so [instance] is already set by the time any provider's `build()`
/// runs and needs a persisted value synchronously (see
/// `ThemeController.build()`).
class LocalPreferences {
  const LocalPreferences._();

  static SharedPreferences? _instance;

  static Future<void> initialize() async {
    _instance = await SharedPreferences.getInstance();
  }

  /// Null only if read before [initialize] finishes (a widget test
  /// that never calls `bootstrap()`, say) -- callers treat that the
  /// same as "nothing saved yet" and fall back to their own default,
  /// exactly like a genuine first launch.
  static SharedPreferences? get instance => _instance;
}

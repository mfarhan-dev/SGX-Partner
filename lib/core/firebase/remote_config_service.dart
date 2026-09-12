import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'remote_config_keys.dart';

final remoteConfigServiceProvider = Provider<RemoteConfigService>(
  (ref) => RemoteConfigService(FirebaseRemoteConfig.instance),
);

/// Thin wrapper over [FirebaseRemoteConfig] — defaults, fetch policy, and
/// typed reads in one place.
///
/// Read values through [remoteConfigProvider] rather than calling this
/// directly from a widget: the provider is what makes a flipped switch
/// rebuild the UI instead of being noticed on the next cold start.
///
/// Nothing here throws. Remote Config is a switchboard, not a data source
/// — when it can't be reached, [RemoteConfigKeys.defaults] is a complete
/// and correct answer, so there is never a reason to fail a caller.
class RemoteConfigService {
  RemoteConfigService(this._remoteConfig);

  final FirebaseRemoteConfig _remoteConfig;

  /// Seeds defaults, sets the fetch policy, and makes one best-effort
  /// fetch. Called from `bootstrap()`, before the first frame.
  Future<void> initialize() async {
    try {
      await _remoteConfig.setDefaults(RemoteConfigKeys.defaults);
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          // Firebase throttles aggressively in release (a repeat fetch
          // inside the window is served from cache, not the network),
          // which is what we want in production but makes testing a switch
          // change impossible. Zero in debug so a flip in the console shows
          // up on the next restart.
          minimumFetchInterval: kDebugMode
              ? Duration.zero
              : const Duration(hours: 1),
        ),
      );
      await _remoteConfig.fetchAndActivate();
    } catch (_) {
      // Deliberately swallowed, and the whole block is inside the try, not
      // just the fetch: a partner opening the app in a workshop with no
      // signal — or on a handset with no Play Services, where every one of
      // these calls fails — must still get past the splash screen. An
      // offline start is the normal case here, not an error path.
    }
  }

  /// Fires whenever the values change server-side while the app is open,
  /// so a kill switch takes effect without waiting for a restart.
  Stream<RemoteConfigUpdate> get onConfigUpdated =>
      _remoteConfig.onConfigUpdated;

  /// Activates values that arrived via [onConfigUpdated]. Fetched values
  /// sit in a staging area until activated; without this the stream event
  /// fires but [snapshot] keeps returning the old numbers.
  Future<void> activate() => _remoteConfig.activate();

  /// Current values, or [RemoteConfigKeys.defaults] if Remote Config
  /// cannot be read at all.
  ///
  /// The fallback is not theoretical: this is called from a provider that
  /// widgets watch, so an uncaught throw here would be a red screen rather
  /// than a missed feature flag.
  RemoteConfigValues snapshot() {
    try {
      return RemoteConfigValues(
        maintenanceMode: _remoteConfig.getBool(
          RemoteConfigKeys.maintenanceMode,
        ),
        maintenanceMessage: _remoteConfig.getString(
          RemoteConfigKeys.maintenanceMessage,
        ),
        qrScanningEnabled: _remoteConfig.getBool(
          RemoteConfigKeys.qrScanningEnabled,
        ),
        withdrawalsEnabled: _remoteConfig.getBool(
          RemoteConfigKeys.withdrawalsEnabled,
        ),
      );
    } catch (_) {
      return const RemoteConfigValues.fallback();
    }
  }
}

/// An immutable read of every Remote Config value at one moment.
///
/// Snapshot rather than live lookups so a widget build can't see one key
/// from before an update and the next key from after it.
class RemoteConfigValues {
  const RemoteConfigValues({
    required this.maintenanceMode,
    required this.maintenanceMessage,
    required this.qrScanningEnabled,
    required this.withdrawalsEnabled,
  });

  /// Mirrors [RemoteConfigKeys.defaults] for the case where Remote Config
  /// itself is unreachable. Kept in sync by hand — the map over there is
  /// `Map<String, Object>`, so it can't be destructured into typed fields
  /// without casts that could themselves throw.
  const RemoteConfigValues.fallback()
    : maintenanceMode = false,
      maintenanceMessage =
          'SGX Partners is briefly down for maintenance. Please try again in a few minutes.',
      qrScanningEnabled = true,
      withdrawalsEnabled = true;

  final bool maintenanceMode;
  final String maintenanceMessage;
  final bool qrScanningEnabled;
  final bool withdrawalsEnabled;
}

/// The app-wide Remote Config values, kept current.
///
/// Watch this from any screen that needs a switch:
/// ```dart
/// final canScan = ref.watch(remoteConfigProvider).qrScanningEnabled;
/// ```
final remoteConfigProvider =
    NotifierProvider<RemoteConfigController, RemoteConfigValues>(
      RemoteConfigController.new,
    );

class RemoteConfigController extends Notifier<RemoteConfigValues> {
  @override
  RemoteConfigValues build() {
    final service = ref.watch(remoteConfigServiceProvider);

    // Real-time updates: Firebase pushes a change while the app is open,
    // we activate it and re-read. This is what lets a kill switch stop a
    // flow mid-session instead of on the next cold start.
    final subscription = service.onConfigUpdated.listen(
      (_) async {
        try {
          await service.activate();
          state = service.snapshot();
        } catch (_) {
          // Keep whatever is already active. A failed activation means
          // stale-but-valid values, which is the correct degradation.
        }
      },
      // The stream itself errors on platforms/devices where the real-time
      // channel can't be established. Without this the error is unhandled
      // and gets reported as a crash.
      onError: (_) {},
    );
    ref.onDispose(subscription.cancel);

    return service.snapshot();
  }
}

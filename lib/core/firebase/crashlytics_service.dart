import 'dart:async';
import 'dart:isolate';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final crashlyticsServiceProvider = Provider<CrashlyticsService>(
  (ref) => CrashlyticsService(FirebaseCrashlytics.instance),
);

/// The app's one route into Crashlytics.
///
/// Nothing else should talk to `FirebaseCrashlytics.instance` directly —
/// going through here is what keeps "do we report in debug builds?" a
/// single decision instead of a per-call-site one.
///
/// Every method here is non-throwing by design. Crash reporting is
/// diagnostics, not a feature: if it breaks, the partner must never see
/// it. That matters twice over for [installErrorHandlers], which runs on
/// the startup path before the first frame, and for the handlers it
/// installs, which run *while an error is already being handled* — a
/// throw from inside one of those loses the original error.
class CrashlyticsService {
  const CrashlyticsService(this._crashlytics);

  final FirebaseCrashlytics _crashlytics;

  /// Points every flavour of uncaught error Flutter has at Crashlytics.
  /// Called once from `bootstrap()`, straight after Firebase init, so that
  /// a crash during the rest of startup is still captured.
  Future<void> installErrorHandlers() async {
    try {
      // Collection off in debug, on everywhere else. Without this, every
      // hot-reload typo and deliberately-thrown test error lands in the
      // real Crashlytics dashboard and buries the crashes that matter.
      // `flutter run --release` on a device still reports, which is how to
      // verify the wiring.
      await _crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
    } catch (_) {
      // A platform-channel failure here (no Play Services, a broken
      // google-services.json) must not stop the app from launching. The
      // handlers below are still worth installing: they degrade to the
      // Flutter defaults rather than disappearing.
    }

    // 1. Errors the Flutter framework catches itself — build, layout, and
    //    paint failures, plus anything thrown inside a widget callback.
    final previousOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      // Chained, not replaced: the default handler is what prints the
      // red-screen dump to the console, and losing that would make local
      // debugging strictly worse.
      previousOnError?.call(details);
      // `.ignore()` rather than fire-and-forget: these are Futures nobody
      // awaits, and an error escaping one would be routed straight into
      // `PlatformDispatcher.onError` below — which calls Crashlytics
      // again. If Crashlytics is what's failing, that's a loop. Reporting
      // a failure to report has nowhere useful to go.
      _crashlytics.recordFlutterFatalError(details).ignore();
    };

    // 2. Errors that escape the framework entirely — a rejected Future
    //    with no catch, a platform-channel reply that throws, anything
    //    past an async gap the framework isn't holding.
    PlatformDispatcher.instance.onError = (error, stack) {
      _crashlytics.recordError(error, stack, fatal: true).ignore();
      // The return value is "did I handle this?", and `true` suppresses
      // Flutter's own console dump. In debug, Crashlytics collection is
      // off, so claiming to have handled it would make the error vanish
      // with nothing printed anywhere. Only claim it in release, where
      // something really did record it.
      return !kDebugMode;
    };

    // 3. Errors on background isolates. `FlutterError.onError` and
    //    `PlatformDispatcher.onError` are both per-isolate, so neither of
    //    the above sees a crash inside a `compute()` call.
    Isolate.current.addErrorListener(
      RawReceivePort((dynamic pair) {
        // Shape-checked rather than destructured or cast. The documented
        // payload is a two-element [error, stackTraceString] list, but
        // this callback runs inside the error path itself: a pattern match
        // or a bad cast failing here would throw while reporting a throw,
        // and the original error would be lost with it.
        if (pair is! List || pair.length < 2) return;
        final stack = pair[1];
        _crashlytics
            .recordError(
              pair[0] ?? 'Unknown isolate error',
              stack is String ? StackTrace.fromString(stack) : null,
              fatal: true,
            )
            .ignore();
      }).sendPort,
    );
  }

  /// Ties subsequent reports to a partner so a "this one user keeps
  /// crashing" report is actionable.
  ///
  /// The profile id (= `auth.uid()`) is deliberately the only identifier
  /// sent. Never the phone number or CNIC — those are the personal data
  /// this app exists to protect, and a crash report is the wrong place for
  /// them.
  Future<void> setUser({
    required String profileId,
    required String role,
  }) async {
    await _guard(() async {
      await _crashlytics.setUserIdentifier(profileId);
      await _crashlytics.setCustomKey('role', role);
    });
  }

  /// Drops the identity again on sign-out, so crashes from the logged-out
  /// shell aren't misattributed to whoever used the phone last.
  Future<void> clearUser() async {
    await _guard(() async {
      await _crashlytics.setUserIdentifier('');
      await _crashlytics.setCustomKey('role', 'signed_out');
    });
  }

  /// Both callers are fire-and-forget from an auth-state listener. Without
  /// this, a failure would surface as an unhandled async error — reported
  /// as a crash by the very handlers above, which is a confusing way to
  /// learn that tagging a username didn't work.
  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      // Diagnostics only; nothing the partner or the app depends on.
    }
  }
}

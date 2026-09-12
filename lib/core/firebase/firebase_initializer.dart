import 'package:firebase_core/firebase_core.dart';

import '../../firebase_options.dart';

/// Brings up the single default [FirebaseApp] that Crashlytics,
/// Messaging, and Remote Config all share.
///
/// Must run before any of those three are touched — each of them
/// resolves `Firebase.app()` internally and throws
/// `[core/no-app]` if nothing has been initialized yet. That's why
/// `bootstrap()` calls this before anything else Firebase-shaped.
class FirebaseInitializer {
  const FirebaseInitializer._();

  static Future<void> initialize() async {
    // Guarded rather than called blind: a hot restart re-runs
    // `bootstrap()` against a native side that still holds the app from
    // the previous run, and a second `initializeApp()` under the same
    // (default) name throws `[core/duplicate-app]`.
    if (Firebase.apps.isNotEmpty) return;

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}

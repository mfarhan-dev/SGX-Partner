import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/firebase/crashlytics_service.dart';
import 'core/firebase/firebase_initializer.dart';
import 'core/firebase/remote_config_service.dart';
import 'core/notifications/push_notifications_service.dart';
import 'core/storage/local_preferences.dart';
import 'core/supabase/supabase_env.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // A ProviderContainer rather than reaching for `FirebaseCrashlytics
  // .instance` and friends directly: startup needs the same service objects
  // the widget tree will use, and handing the container to
  // UncontrolledProviderScope below means nothing is built twice.
  final container = ProviderContainer();

  await _initializeFirebase(container);

  await LocalPreferences.initialize();
  await Supabase.initialize(
    url: SupabaseEnv.url,
    publishableKey: SupabaseEnv.publishableKey,
  );

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const SGXPartnersApp(),
    ),
  );
}

/// Brings up crash reporting, Remote Config, and push — in that order,
/// and none of them able to stop the app from starting.
///
/// Every line below runs *before* `runApp()`, so an escaping exception is
/// not an error message, it's a black screen on launch. And these are not
/// hypothetical failures: `Firebase.initializeApp` and everything
/// downstream of it fail on an Android handset with no Google Play
/// Services, which is a real share of the low-cost phones this app's
/// partners use.
///
/// All three are diagnostics or switches. None of them is the app. Losing
/// them should cost exactly what they provide and nothing more, so the
/// whole block degrades rather than throws.
Future<void> _initializeFirebase(ProviderContainer container) async {
  try {
    // First, so that a crash anywhere in the rest of startup is itself
    // reported.
    await FirebaseInitializer.initialize();
  } catch (_) {
    // Without a FirebaseApp the three subsystems below have nothing to
    // attach to, and each would only throw `[core/no-app]` in turn. Stop
    // here and let the app run on Supabase alone.
    return;
  }

  // Each of these is individually non-throwing (see their own doc
  // comments), so one failing doesn't deny the other two.
  await container.read(crashlyticsServiceProvider).installErrorHandlers();

  // Remote Config before the first frame: a kill switch that only takes
  // effect a second after the UI is already on screen isn't much of a kill
  // switch. Bounded by its own 10s fetch timeout.
  await container.read(remoteConfigServiceProvider).initialize();

  // Registers the background handler, creates the Android channel, and
  // asks for notification permission. Session-dependent work (storing the
  // token, routing a tapped notification) is the coordinator's job and
  // starts with the widget tree.
  await container.read(pushNotificationsServiceProvider).initialize();
}

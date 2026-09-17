import 'dart:async';
import 'dart:convert';
import 'dart:ui' show Color;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../firebase/firebase_initializer.dart';
import 'push_message.dart';

/// Entry point for pushes that arrive while the app is backgrounded or
/// killed.
///
/// This runs in its own isolate with an empty world: no `ProviderScope`,
/// no widget tree, nothing `bootstrap()` set up. Hence the explicit
/// Firebase init, and hence `@pragma('vm:entry-point')` — without it the
/// AOT compiler tree-shakes this function away and release builds
/// silently stop waking up.
///
/// Deliberately close to a no-op. A notification-type payload is drawn by
/// the OS itself (via the default channel declared in
/// AndroidManifest.xml), so there is nothing to display here. Resist
/// putting real work in this function: it gets seconds of wall time and
/// cannot touch the UI.
@pragma('vm:entry-point')
Future<void> handleBackgroundMessage(RemoteMessage message) async {
  try {
    await FirebaseInitializer.initialize();
  } catch (_) {
    // There is nothing else in this isolate to catch a throw, and no UI to
    // show it in. Failing quietly loses one background wake-up; throwing
    // would be an unhandled error in a bare isolate, which is worse and
    // just as invisible.
  }
}

final pushNotificationsServiceProvider = Provider<PushNotificationsService>((
  ref,
) {
  final service = PushNotificationsService();
  ref.onDispose(service.dispose);
  return service;
});

/// Owns everything FCM: permission, token, and the three different ways a
/// push can reach the app (foreground, background-tap, cold-start-tap).
class PushNotificationsService {
  PushNotificationsService();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Must match `com.google.firebase.messaging.default_notification_channel_id`
  /// in AndroidManifest.xml. If the two drift apart, Android quietly files
  /// background notifications under a default low-importance channel —
  /// they arrive, but with no heads-up banner and no sound, which looks
  /// exactly like "push is broken".
  static const _androidChannel = AndroidNotificationChannel(
    'sgx_partners_high_importance',
    'SGX Partners alerts',
    description:
        'Rewards credited, withdrawal updates, and new campaigns from SGX.',
    importance: Importance.high,
  );

  /// AppColors.primary, mirrored from `@color/sgx_notification_accent`.
  /// Duplicated rather than shared because Android resources aren't
  /// reachable from Dart — if one changes, change both.
  static const _brandAccent = Color(0xFFC2272B);

  final _tapController = StreamController<PushMessage>.broadcast();
  final _tokenController = StreamController<String>.broadcast();
  final _messageController = StreamController<PushMessage>.broadcast();

  /// Notifications the partner tapped, from any app state. Listened to
  /// once, app-wide, by `PushNotificationsCoordinator`.
  Stream<PushMessage> get onNotificationTapped => _tapController.stream;

  /// Every push that arrives while the app is in the foreground --
  /// whether or not the partner ever taps it. Distinct from
  /// [onNotificationTapped]: a reward/withdrawal/campaign push landing
  /// while Home is already open should refresh that data right away,
  /// not wait for a tap that may never come. Only fires for
  /// foreground arrivals -- a background/killed-state push runs
  /// `handleBackgroundMessage` in a bare isolate with no `Ref` to
  /// invalidate anything with; that data catches up whenever the
  /// partner next taps the notification or the provider naturally
  /// refetches (cold start, or after their own action).
  Stream<PushMessage> get onMessageReceived => _messageController.stream;

  /// Every FCM token this install has, including refreshes. Not a one-shot
  /// getter because FCM rotates tokens on its own schedule — a stored
  /// token that is never updated is the usual cause of "notifications
  /// stopped arriving after a few weeks".
  Stream<String> get onTokenChanged => _tokenController.stream;

  /// Sets up every FCM path. Called from `bootstrap()` **before the first
  /// frame**, which is why it cannot be allowed to throw.
  ///
  /// This is not defensive padding. `requestPermission()` and the local
  /// notification plugin both fail outright on an Android handset with no
  /// Google Play Services — common on the low-cost phones this app's
  /// partners actually use. Letting that propagate would mean the app
  /// never reaches `runApp()` and the partner sees a black screen, having
  /// lost the whole app because notifications aren't available.
  ///
  /// Failing here costs notifications. Nothing else.
  Future<void> initialize() async {
    try {
      // Registered before anything else: this hands the handler to the
      // native SDK, and a push that lands during the rest of startup should
      // already have somewhere to go.
      FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

      await _configureLocalNotifications();
      await _requestPermission();
      await _configureForegroundPresentation();

      FirebaseMessaging.onMessage.listen(_onForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(
        (message) => _emitTap(PushMessage.fromRemoteMessage(message)),
      );

      _messaging.onTokenRefresh.listen(_tokenController.add);
    } catch (_) {
      // Degraded, not broken — see above.
    }
  }

  /// The tap that launched the app from a fully terminated state.
  ///
  /// Not delivered through [onNotificationTapped], because the tap
  /// happened before anything was listening. Has to be asked for once,
  /// and only once — FCM keeps returning the same message until the app
  /// is killed again, so a second caller would navigate twice.
  Future<PushMessage?> takeLaunchMessage() async {
    try {
      final message = await _messaging.getInitialMessage();
      return message == null ? null : PushMessage.fromRemoteMessage(message);
    } catch (_) {
      // Same reasoning as `currentToken()`: on a device where FCM isn't
      // available this throws rather than returning null, and the caller
      // only wants "is there one?".
      return null;
    }
  }

  /// This install's current FCM token, or null if it can't be had yet.
  ///
  /// Null is routine on iOS rather than exceptional: the token isn't
  /// available until APNs has handed over its own, which needs the Push
  /// Notifications capability, a real device, and network. The
  /// [onTokenChanged] stream covers the "arrives a moment later" case.
  Future<String?> currentToken() async {
    try {
      return await _messaging.getToken();
    } catch (_) {
      return null;
    }
  }

  /// Invalidates this install's token — called on sign-out so pushes meant
  /// for the partner who just left don't land on a shared phone.
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
    } catch (_) {
      // Best-effort. A failure here means the token outlives the session,
      // which the server-side clear of `profiles.fcm_token` already
      // covers; it must never be allowed to break sign-out.
    }
  }

  Future<void> dispose() async {
    await _tapController.close();
    await _tokenController.close();
    await _messageController.close();
  }

  Future<void> _configureLocalNotifications() async {
    await _localNotifications.initialize(
      settings: const InitializationSettings(
        // Not the launcher icon: see the note on
        // `default_notification_icon` in AndroidManifest.xml — an icon with
        // no alpha channel renders as a plain white square.
        android: AndroidInitializationSettings('@drawable/ic_stat_sgx'),
        // All false: `firebase_messaging` asks for these permissions
        // itself in `_requestPermission()`, and asking twice would show
        // the partner two system prompts back to back.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: _onLocalNotificationTapped,
    );

    // Creating the channel up front (rather than letting the first
    // notification create it) is what makes the manifest's default
    // channel id resolve to a high-importance channel. Re-creating an
    // existing channel is a no-op, so this is safe on every start.
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidChannel);
  }

  Future<void> _requestPermission() async {
    // Covers both platforms: the iOS/APNs authorisation prompt, and on
    // Android 13+ the POST_NOTIFICATIONS runtime grant. A denial is not
    // an error — the partner simply gets no pushes, and everything else
    // in the app keeps working.
    await _messaging.requestPermission();
  }

  Future<void> _configureForegroundPresentation() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return;

    // iOS can draw a notification banner itself even while the app is
    // foregrounded, which Android cannot. Letting it do so is why
    // [_onForegroundMessage] only posts a local notification on Android:
    // doing it on both would show the same push twice on iOS.
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// A push that arrived while the partner is actively using the app.
  ///
  /// Two independent things happen here, deliberately in this order:
  /// emit to [onMessageReceived] first (on every platform -- data
  /// refresh doesn't depend on whether a banner gets drawn), then, on
  /// Android only, post an equivalent local notification into our own
  /// channel (iOS already draws its own banner while foregrounded, via
  /// [_configureForegroundPresentation]; doing it on both would show
  /// the same push twice there).
  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final push = PushMessage.fromRemoteMessage(message);
    if (!_messageController.isClosed) _messageController.add(push);

    if (defaultTargetPlatform != TargetPlatform.android) return;

    final title = push.title;
    final body = push.body;
    // Data-only pushes (a silent balance refresh, say) carry no text;
    // there is nothing meaningful to draw for one.
    if (title == null && body == null) return;

    try {
      await _localNotifications.show(
        // Hashed rather than incremented: a stable id per message means a
        // redelivered push replaces its own notification instead of stacking
        // a duplicate.
        //
        // Masked because the plugin rejects anything outside a signed 32-bit
        // int with an ArgumentError, and Dart's String.hashCode is not bound
        // to that range — an unmasked hash would throw on some messages and
        // not others.
        id: push.id.hashCode & 0x7FFFFFFF,
        title: title,
        body: body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            importance: Importance.high,
            priority: Priority.high,
            // Kept identical to the manifest defaults the OS uses for
            // background pushes, so the same event looks the same however it
            // arrived.
            icon: 'ic_stat_sgx',
            color: _brandAccent,
          ),
        ),
        // The deep link has to survive the round trip out to the OS and
        // back, since the tap callback gets only this string.
        payload: jsonEncode(push.data),
      );
    } catch (_) {
      // An undrawable notification is not worth crashing an app the
      // partner is actively using — this runs while they're on screen.
    }
  }

  void _onLocalNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    final Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(payload) as Map<String, dynamic>;
    } catch (_) {
      return;
    }

    // Rebuilt through the same factory the FCM paths use, so the deep-link
    // validation in [PushMessage] applies here too.
    _emitTap(PushMessage.fromRemoteMessage(RemoteMessage(data: decoded)));
  }

  /// Taps can arrive from the OS after [dispose] has closed the
  /// controller — a hot restart is the easy way to see it — and adding to
  /// a closed StreamController throws a StateError.
  void _emitTap(PushMessage message) {
    if (_tapController.isClosed) return;
    _tapController.add(message);
  }
}

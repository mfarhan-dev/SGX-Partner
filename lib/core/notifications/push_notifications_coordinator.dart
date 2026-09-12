import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_router.dart';
import '../auth/auth_controller.dart';
import '../auth/auth_state.dart';
import '../firebase/crashlytics_service.dart';
import 'push_message.dart';
import 'push_notifications_service.dart';
import 'push_token_repository.dart';

final pushNotificationsCoordinatorProvider =
    Provider<PushNotificationsCoordinator>((ref) {
      final coordinator = PushNotificationsCoordinator(ref);

      // Subscribed here, in the provider body, rather than inside
      // `start()`: `ref.listen` is only contractually safe during a
      // provider's build, and this provider is never auto-disposed, so the
      // subscription lives as long as the app does.
      //
      // Explicitly NOT `fireImmediately`. The initial state is always
      // `signedOut`, and treating that as a sign-out would run the
      // teardown below on every cold start -- deleting this install's FCM
      // token and blanking `profiles.fcm_token` for a partner who is in
      // fact still logged in, forcing a brand-new token each launch.
      // Only real transitions are acted on.
      ref.listen<AuthState>(authControllerProvider, coordinator.onAuthChanged);

      ref.onDispose(coordinator.dispose);
      return coordinator;
    });

/// The one place that knows how push, the session, and navigation relate.
///
/// Three jobs, all of which need to see more than one subsystem at once,
/// which is why they live together rather than inside
/// [PushNotificationsService]:
///
/// * register this install's FCM token against the partner who just
///   signed in, and clear it when they leave;
/// * tag Crashlytics reports with that same partner;
/// * turn a tapped notification into navigation, once there is somewhere
///   sane to navigate to.
///
/// Started once, from the root widget.
class PushNotificationsCoordinator {
  PushNotificationsCoordinator(this._ref);

  final Ref _ref;

  StreamSubscription<PushMessage>? _tapSubscription;
  StreamSubscription<String>? _tokenSubscription;
  GoRouter? _router;

  /// A tap we've accepted but can't act on yet — see
  /// [_flushPendingDeepLink].
  String? _pendingDeepLink;
  bool _started = false;

  /// Called from the root widget's first post-frame callback, and not
  /// awaited by anyone — so a throw escaping here would surface as an
  /// unhandled async error and be reported as a crash. Notifications not
  /// wiring up is a degradation, not a crash, so it is caught.
  Future<void> start() async {
    // Idempotent: the root widget can be re-created (hot reload, or a
    // locale/theme change rebuilding above it) and starting twice would
    // double every subscription, so every tap would navigate twice.
    if (_started) return;
    _started = true;

    try {
      final service = _ref.read(pushNotificationsServiceProvider);

      _tapSubscription = service.onNotificationTapped.listen(_onTap);
      _tokenSubscription = service.onTokenChanged.listen(_saveToken);

      // The router tells us when navigation has settled enough to honour a
      // deep link — see [_flushPendingDeepLink] for why that matters.
      _router = _ref.read(appRouterProvider);
      _router!.routerDelegate.addListener(_flushPendingDeepLink);

      // Covers the narrow race where the session was restored before this
      // provider existed, so the `ref.listen` above never saw the
      // signed-out → signed-in transition. Everything it does is
      // idempotent, so running it here as well costs nothing.
      _onSignedIn(_ref.read(authControllerProvider));

      // A tap that launched the app from cold. Asked for last, so the
      // listeners above are already in place by the time it resolves.
      final launch = await service.takeLaunchMessage();
      if (launch != null) _onTap(launch);
    } catch (_) {
      // Whatever did get wired up above stays wired up.
    }
  }

  Future<void> dispose() async {
    _router?.routerDelegate.removeListener(_flushPendingDeepLink);
    await _tapSubscription?.cancel();
    await _tokenSubscription?.cancel();
  }

  void onAuthChanged(AuthState? previous, AuthState next) {
    if (next.status == AuthStatus.signedIn) {
      _onSignedIn(next);
      return;
    }

    // Only a genuine sign-out, never the `signedOut` the app merely starts
    // life in — see the note on the `ref.listen` call above.
    //
    // The FCM token is deliberately not touched here: clearing
    // `profiles.fcm_token` needs a live JWT, and by the time this state
    // change lands the session is already gone. `AuthController.signOut()`
    // does that part first, while it still can.
    if (next.status == AuthStatus.signedOut &&
        previous?.status == AuthStatus.signedIn) {
      _pendingDeepLink = null;
      _ref.read(crashlyticsServiceProvider).clearUser();
    }
  }

  void _onSignedIn(AuthState auth) {
    final profile = auth.profile;
    if (auth.status != AuthStatus.signedIn || profile == null) return;

    _ref
        .read(crashlyticsServiceProvider)
        .setUser(profileId: profile.id, role: profile.role.name);

    // Now that there's a row to write to, register whatever token this
    // install already has. Refreshes after this point arrive via
    // `onTokenChanged`.
    _registerCurrentToken();

    // A link that arrived pre-login can be honoured now.
    _flushPendingDeepLink();
  }

  void _onTap(PushMessage message) {
    final deepLink = message.deepLink;
    // A notification with no route is still a perfectly good
    // notification — it just has nothing to open.
    if (deepLink == null) return;

    _pendingDeepLink = deepLink;
    _flushPendingDeepLink();
  }

  /// Navigates to a queued deep link, but only once the app is actually in
  /// a state where that makes sense.
  ///
  /// Both guards are load-bearing:
  ///
  /// * **Signed in.** A deep link to `/mechanic/wallet` from the login
  ///   screen would land on a screen with no session behind it.
  /// * **Off the splash screen.** `SplashScreen` finishes with its own
  ///   `context.go(...)` once the session is restored. Navigating before
  ///   that happens looks like it worked and is then silently thrown away
  ///   — the splash's redirect runs later, so the splash wins.
  ///
  /// So the link is held, and this is retried on every auth change and
  /// every route change until one attempt qualifies.
  void _flushPendingDeepLink() {
    final deepLink = _pendingDeepLink;
    final router = _router;
    if (deepLink == null || router == null) return;

    final auth = _ref.read(authControllerProvider);
    if (auth.status != AuthStatus.signedIn) return;
    final profile = auth.profile;
    if (profile == null || !profile.isComplete) return;

    final location = router.routerDelegate.currentConfiguration.uri.path;
    if (location == '/splash' || location.startsWith('/auth/')) return;

    _pendingDeepLink = null;
    // Deferred a microtask because one caller is the router delegate's own
    // listener: navigating from inside a `notifyListeners` pass is how you
    // get "setState() or markNeedsBuild() called during build".
    //
    // `push`, not `go`: the partner tapped a notification while the app had
    // a perfectly good screen underneath, and back should return them to
    // it. Same reasoning as every card tap in this app.
    //
    // Caught because `deepLink` is a string chosen by whoever sent the
    // push, not by this app. `PushMessage` guarantees it's an internal
    // path, but not that the path exists — a typo in a campaign push must
    // leave the partner on the screen they were already on.
    Future.microtask(() {
      try {
        router.push(deepLink);
      } catch (_) {}
    });
  }

  Future<void> _registerCurrentToken() async {
    final token = await _ref
        .read(pushNotificationsServiceProvider)
        .currentToken();
    if (token == null) return;
    await _saveToken(token);
  }

  Future<void> _saveToken(String token) =>
      _ref.read(pushTokenRepositoryProvider).saveToken(token);
}

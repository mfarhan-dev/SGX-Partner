import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_router.dart';
import '../../roles/mechanic/profile/data/mechanic_profile_providers.dart';
import '../../roles/mechanic/wallet/data/mechanic_wallet_providers.dart';
import '../../roles/wholesaler/profile/data/wholesaler_profile_providers.dart';
import '../../roles/wholesaler/qr_progress/data/wholesaler_qr_progress_providers.dart';
import '../../roles/wholesaler/wallet/data/khata_ledger_providers.dart';
import '../../shared/campaigns/data/active_campaigns_providers.dart';
import '../../shared/withdrawals/data/withdrawals_providers.dart';
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
/// Four jobs, all of which need to see more than one subsystem at once,
/// which is why they live together rather than inside
/// [PushNotificationsService]:
///
/// * register this install's FCM token against the partner who just
///   signed in, and clear it when they leave;
/// * tag Crashlytics reports with that same partner;
/// * turn a tapped notification into navigation, once there is somewhere
///   sane to navigate to;
/// * refresh whichever cached provider(s) a push's `type` says changed
///   -- see [_refreshFor]. This is deliberately the app's only "pull to
///   refresh" for Home, Withdrawals, and Campaigns: every value shown
///   there (balance, lifetime earned, pending, the campaigns list) only
///   ever changes through an action that already raises a
///   `user_notifications` row server-side, so reacting to that push is
///   both necessary and sufficient -- a manual pull-to-refresh would
///   only ever recheck for the same events this already reacts to
///   live. The one gap this can't close: a push that arrives while the
///   app is backgrounded (not killed, not foregrounded) and is never
///   tapped runs no app code at all (see
///   [PushNotificationsService.onMessageReceived]) -- that data is
///   stale until the partner taps it, backgrounds-then-foregrounds
///   into a fresh push, or the provider refetches for its own reason.
///
/// Started once, from the root widget.
class PushNotificationsCoordinator {
  PushNotificationsCoordinator(this._ref);

  final Ref _ref;

  StreamSubscription<PushMessage>? _tapSubscription;
  StreamSubscription<PushMessage>? _messageSubscription;
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
      _messageSubscription = service.onMessageReceived.listen(
        (message) => _refreshFor(message.type),
      );
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
    await _messageSubscription?.cancel();
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
    // Refreshed unconditionally, before the deep-link check below --
    // whatever screen the partner lands on (or is already looking at
    // under the notification shade) should show the fresh number, not
    // whatever was cached from before this event happened.
    _refreshFor(message.type);

    final deepLink = message.deepLink;
    // A notification with no route is still a perfectly good
    // notification — it just has nothing to open.
    if (deepLink == null) return;

    _pendingDeepLink = deepLink;
    _flushPendingDeepLink();
  }

  /// The single map from "what happened server-side" to "what's now
  /// stale on-device" -- see the class doc comment for why this
  /// replaces pull-to-refresh rather than sitting alongside it.
  /// Invalidating a provider nobody is currently watching is free (it
  /// just refetches lazily next time something watches it), so this
  /// never checks which screen is on-screen right now.
  void _refreshFor(String? type) {
    switch (type) {
      case 'qr_reward_credited':
        // Both roles invalidated unconditionally rather than branching
        // on the signed-in partner's own role: a wholesaler's reward
        // is credited by a MECHANIC's scan, so the push reaches the
        // wholesaler while the app already believes it's mid-session
        // as that wholesaler -- there is no cross-role case where
        // invalidating the "wrong" role's providers could ever fire
        // against a live session, and skipping the branch removes a
        // whole class of "forgot to handle the other role" bug.
        _ref.invalidate(mechanicProfileDataProvider);
        _ref.invalidate(mechanicLifetimeEarnedProvider);
        _ref.invalidate(mechanicWalletActivityProvider);
        _ref.invalidate(wholesalerProfileDataProvider);
        _ref.invalidate(wholesalerLifetimeEarnedProvider);
        _ref.invalidate(khataLedgerProvider);
        // A wholesaler's own scanned/total counts per invoice line --
        // the exact same qr_codes row flipping to 'scanned' that
        // credits the reward above also moves this. Left out of the
        // first pass; same event, same fix.
        _ref.invalidate(wholesalerQrProgressProvider);
      case 'withdrawal_submitted':
      case 'withdrawal_disputed':
      case 'withdrawal_auto_confirmed':
      case 'withdrawal_payment_sent':
      case 'withdrawal_refunded':
        // withdrawalsListProvider is what Home's own `pending` figure
        // is derived from client-side -- invalidating it is the whole
        // fix, no separate "pending" state to touch. The profile
        // providers are included too: a refund changes points_balance
        // server-side, and invalidating the other role's profile when
        // it didn't change is a wasted refetch, not a bug.
        _ref.invalidate(withdrawalsListProvider);
        _ref.invalidate(mechanicProfileDataProvider);
        _ref.invalidate(wholesalerProfileDataProvider);
      case 'campaign_published':
        _ref.invalidate(activeCampaignsProvider);
    }
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
    // `push` for a real pushed screen (a campaign, a product, a
    // withdrawal) -- the partner tapped a notification while the app had
    // a perfectly good screen underneath, and back should return them to
    // it. Same reasoning as every card tap in this app.
    //
    // `go`, never `push`, for a bottom-nav TAB (see `_shellTabRoutes`) --
    // same rule the in-app bell already follows for these exact
    // destinations (`sgx_app_bar.dart`, each Home screen's own bell).
    // Pushing a tab route while a *different* tab is already lower in
    // the stack puts two copies of the same ShellRoute-wrapped subtree
    // in one Navigator at once, which go_router cannot key uniquely --
    // this is exactly what crashed
    // (`NavigatorState._debugCheckDuplicatedPageKeys`) scanning a QR
    // code (pushes /mechanic/scan on top of Home), backgrounding, then
    // tapping the reward-credited push (tried to push /mechanic/wallet
    // on top of that). A campaign push worked fine in the same test
    // because /campaigns sits outside the shell entirely.
    //
    // Caught because `deepLink` is a string chosen by whoever sent the
    // push, not by this app. `PushMessage` guarantees it's an internal
    // path, but not that the path exists — a typo in a campaign push must
    // leave the partner on the screen they were already on.
    Future.microtask(() {
      try {
        if (_shellTabRoutes.contains(deepLink)) {
          router.go(deepLink);
        } else {
          router.push(deepLink);
        }
      } catch (_) {}
    });
  }

  /// Every route nested under `ShellRoute` in app_routes.dart -- the
  /// bottom-nav tabs, not a pushed detail screen. See
  /// `_flushPendingDeepLink`'s own comment for why these specifically
  /// must never be `push`ed.
  static const _shellTabRoutes = {
    '/products',
    '/mechanic/home',
    '/mechanic/wallet',
    '/mechanic/profile',
    '/wholesaler/home',
    '/wholesaler/qr-progress',
    '/wholesaler/wallet',
    '/wholesaler/profile',
  };

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

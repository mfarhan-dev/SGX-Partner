import 'package:firebase_messaging/firebase_messaging.dart';

/// One incoming push, flattened out of FCM's [RemoteMessage] into the
/// shape the app actually cares about.
///
/// Worth having as its own type for two reasons: it keeps
/// `firebase_messaging` out of the widget layer, and it puts the
/// defensive parsing of the `data` map — which is attacker-adjacent
/// input, since it decides where the app navigates — in exactly one
/// place.
class PushMessage {
  const PushMessage({
    required this.id,
    required this.data,
    this.title,
    this.body,
    this.deepLink,
  });

  factory PushMessage.fromRemoteMessage(RemoteMessage message) {
    final data = message.data.map(
      (key, value) => MapEntry(key, value?.toString() ?? ''),
    );

    return PushMessage(
      // `messageId` is null for some locally-constructed messages, so fall
      // back to something stable-ish rather than letting it be nullable
      // all the way down to the notification id.
      id: message.messageId ?? DateTime.now().microsecondsSinceEpoch.toString(),
      data: data,
      // A notification-type push carries these in `notification`; a
      // data-only push has to put them in `data` instead. Accept both so
      // the backend isn't forced into one style.
      title: message.notification?.title ?? _nonEmpty(data['title']),
      body: message.notification?.body ?? _nonEmpty(data['body']),
      deepLink: _parseDeepLink(data),
    );
  }

  final String id;
  final Map<String, String> data;
  final String? title;
  final String? body;

  /// The `user_notifications.type` this push was raised from (e.g.
  /// `qr_reward_credited`, `withdrawal_payment_sent`,
  /// `campaign_published`) -- see `notify_push_on_user_notification()`
  /// on the DB side, which always forwards it. Used to decide which
  /// cached provider(s) a received/tapped push should invalidate,
  /// without hardcoding a route-to-provider mapping in two places.
  String? get type => _nonEmpty(data['type']);

  /// In-app route to open when the partner taps this notification, e.g.
  /// `/mechanic/withdrawals/abc-123`. Null when the push is purely
  /// informational.
  final String? deepLink;

  /// Only ever an app-internal path.
  ///
  /// The allow-check is not ceremony: this string is handed to GoRouter,
  /// and anything that can send this project's FCM messages would
  /// otherwise be able to aim the app at an arbitrary URL. Absolute URLs
  /// and protocol-relative `//host` forms are both rejected; only a
  /// single-slash-rooted path gets through.
  static String? _parseDeepLink(Map<String, String> data) {
    final raw = _nonEmpty(data['deep_link']) ?? _nonEmpty(data['route']);
    if (raw == null) return null;
    if (!raw.startsWith('/') || raw.startsWith('//')) return null;
    return raw;
  }

  static String? _nonEmpty(String? value) =>
      (value == null || value.isEmpty) ? null : value;
}

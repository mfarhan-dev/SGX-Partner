import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/auth/auth_controller.dart';

/// There is no separate Notifications screen -- every real
/// notification type wired up so far (withdrawal paid/confirmed/
/// refunded) already duplicates a row Activity already shows, so a
/// second list was just a second door to the same room. This is just
/// the badge: how many of this partner's `user_notifications` rows
/// are unread. RLS already scopes reads/updates to `auth.uid() =
/// user_id`, same as `withdrawals`/`payout_accounts` -- no RPC
/// wrapper needed.
///
/// Session-cached like every other list in this app, NOT
/// `.autoDispose` -- invalidate after [markAllNotificationsRead] so
/// the badge clears immediately.
final unreadNotificationsCountProvider = FutureProvider<int>((ref) async {
  ref.watch(authControllerProvider);
  final client = Supabase.instance.client;
  final rows = await client
      .from('user_notifications')
      .select('id')
      .eq('is_read', false);
  return (rows as List).length;
});

/// Called when the bell is tapped -- the partner is being taken
/// straight to Activity instead of a separate list, so "seeing" these
/// notifications means landing there, not tapping each one
/// individually.
Future<void> markAllNotificationsRead(WidgetRef ref) async {
  final client = Supabase.instance.client;
  await client
      .from('user_notifications')
      .update({'is_read': true})
      .eq('is_read', false);
  ref.invalidate(unreadNotificationsCountProvider);
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final pushTokenRepositoryProvider = Provider<PushTokenRepository>(
  (ref) => SupabasePushTokenRepository(),
);

abstract interface class PushTokenRepository {
  /// Stores this install's FCM token against the signed-in partner, so the
  /// backend has somewhere to send to.
  Future<void> saveToken(String token);

  /// Forgets the token on sign-out.
  Future<void> clearToken();
}

/// Writes to the pre-existing `profiles.fcm_token` column.
///
/// One token per profile, not a separate `device_tokens` table — which is
/// a real limitation worth knowing: a partner signed in on two phones will
/// only ever receive pushes on whichever one registered last. That matches
/// the column the backend already reads, and this app's partners are
/// single-device in practice. Multi-device needs its own table and a
/// migration; it is not something to fake from the client.
///
/// No RLS problem to solve here: the existing `profiles_update` policy
/// already scopes an update to `auth.uid() = id`, so a partner can only
/// ever write their own token.
class SupabasePushTokenRepository implements PushTokenRepository {
  SupabasePushTokenRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Future<void> saveToken(String token) => _write(token);

  @override
  Future<void> clearToken() => _write(null);

  Future<void> _write(String? token) async {
    final userId = _client.auth.currentUser?.id;
    // No session means no row to write to. Happens legitimately: the token
    // is often ready before the partner has logged in, and on sign-out the
    // order of teardown isn't guaranteed.
    if (userId == null) return;

    try {
      await _client
          .from('profiles')
          .update({'fcm_token': token})
          .eq('id', userId);
    } catch (_) {
      // Never fatal. Failing to register a token costs the partner
      // notifications until the next app start retries — it must not break
      // login, and it must not break sign-out.
    }
  }
}

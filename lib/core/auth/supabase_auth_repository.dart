import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../shared/models/app_role.dart';
import '../../shared/models/profile_summary.dart';
import 'auth_repository.dart';

/// Real phone-OTP auth backed by Supabase.
///
/// The role decision itself (wholesaler vs. mechanic vs. brand-new
/// mechanic) is not made here — it lives in the `claim_partner_profile`
/// Postgres function, which is the only thing that can safely read the
/// caller's own verified phone (`auth.users.phone`) and match it against
/// the `wholesalers`/`mechanics` tables. This class is just the client
/// side of that call.
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final supabase.SupabaseClient _client;

  @override
  Future<ProfileSummary?> restoreSession() async {
    if (_client.auth.currentSession == null) return null;
    return _claimProfile();
  }

  @override
  Future<void> sendOtp(String phoneNumber) async {
    try {
      await _client.auth.signInWithOtp(phone: _toE164(phoneNumber));
    } on supabase.AuthException catch (error) {
      throw AuthException(error.message);
    }
  }

  @override
  Future<ProfileSummary?> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      await _client.auth.verifyOTP(
        type: supabase.OtpType.sms,
        phone: _toE164(phoneNumber),
        token: otp,
      );
    } on supabase.AuthException catch (error) {
      throw AuthException(error.message);
    }
    return _claimProfile();
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  /// Calls `claim_partner_profile()`, which links this session to the
  /// matching wholesaler/mechanic record on first login, or simply
  /// returns the already-claimed profile on every login after that.
  Future<ProfileSummary?> _claimProfile() async {
    final rows = await _client.rpc('claim_partner_profile') as List<dynamic>;
    if (rows.isEmpty) return null;

    final row = rows.first as Map<String, dynamic>;
    return ProfileSummary(
      id: row['id'] as String,
      displayName: row['display_name'] as String,
      phoneNumber: row['phone_number'] as String,
      role: _roleFromDb(row['role'] as String),
      isActive: row['is_active'] as bool,
      isComplete: row['is_complete'] as bool,
    );
  }

  AppRole _roleFromDb(String value) => switch (value) {
    'wholesaler' => AppRole.wholesaler,
    'mechanic' => AppRole.mechanic,
    _ => AppRole.unknown,
  };

  /// wholesalers/mechanics store local Pakistani numbers (03XXXXXXXXX),
  /// but Supabase Auth needs E.164 to actually deliver the SMS.
  String _toE164(String localNumber) {
    final digits = localNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final national = digits.startsWith('0') ? digits.substring(1) : digits;
    return '+92$national';
  }
}

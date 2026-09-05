import '../../shared/models/profile_summary.dart';

abstract interface class AuthRepository {
  /// Checks for an existing signed-in session (e.g. on app relaunch) and
  /// returns the associated profile, or `null` if there is none.
  Future<ProfileSummary?> restoreSession();

  Future<void> sendOtp(String phoneNumber);

  Future<ProfileSummary?> verifyOtp({
    required String phoneNumber,
    required String otp,
  });

  Future<void> signOut();
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;
}

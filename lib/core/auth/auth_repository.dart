import '../../shared/models/profile_summary.dart';

abstract interface class AuthRepository {
  Future<void> restoreSession();

  Future<void> sendOtp(String phoneNumber);

  Future<ProfileSummary?> verifyOtp({
    required String phoneNumber,
    required String otp,
  });

  Future<void> signOut();
}

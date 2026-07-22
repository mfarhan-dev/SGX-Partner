import '../../shared/models/app_role.dart';
import '../../shared/models/profile_summary.dart';
import 'auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  const MockAuthRepository();

  @override
  Future<void> restoreSession() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  @override
  Future<void> sendOtp(String phoneNumber) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
  }

  @override
  Future<ProfileSummary?> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (otp != '123456') {
      throw const AuthException('Invalid OTP. Please try again.');
    }

    if (phoneNumber.endsWith('0000')) {
      return const ProfileSummary(
        id: 'wholesaler-1',
        displayName: 'SGX Wholesale Partner',
        phoneNumber: '03000000000',
        role: AppRole.wholesaler,
        isActive: true,
        isComplete: true,
      );
    }

    return ProfileSummary(
      id: 'mechanic-1',
      displayName: 'Mechanic Partner',
      phoneNumber: phoneNumber,
      role: AppRole.mechanic,
      isActive: true,
      isComplete: true,
    );
  }

  @override
  Future<void> signOut() async {}
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;
}

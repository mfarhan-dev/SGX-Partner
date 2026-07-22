import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_repository.dart';
import 'auth_state.dart';
import 'mock_auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => const MockAuthRepository(),
);

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState.signedOut();

  Future<void> restoreSession() async {
    state = const AuthState.checking();
    await ref.read(authRepositoryProvider).restoreSession();
    state = const AuthState.signedOut();
  }

  Future<void> sendOtp(String phoneNumber) async {
    state = AuthState(status: AuthStatus.checking, phoneNumber: phoneNumber);
    await ref.read(authRepositoryProvider).sendOtp(phoneNumber);
    state = AuthState(status: AuthStatus.otpSent, phoneNumber: phoneNumber);
  }

  Future<void> verifyOtp(String otp) async {
    final phoneNumber = state.phoneNumber;
    if (phoneNumber == null) return;

    state = state.copyWith(status: AuthStatus.checking);
    try {
      final profile = await ref
          .read(authRepositoryProvider)
          .verifyOtp(phoneNumber: phoneNumber, otp: otp);

      if (profile == null) {
        state = AuthState(
          status: AuthStatus.signedIn,
          phoneNumber: phoneNumber,
          profile: null,
        );
        return;
      }

      if (!profile.isActive || !profile.role.isPartner) {
        state = AuthState(
          status: AuthStatus.accountUnavailable,
          phoneNumber: phoneNumber,
          profile: profile,
        );
        return;
      }

      state = AuthState(
        status: AuthStatus.signedIn,
        phoneNumber: phoneNumber,
        profile: profile,
      );
    } on AuthException catch (error) {
      state = AuthState(
        status: AuthStatus.otpSent,
        phoneNumber: phoneNumber,
        errorMessage: error.message,
      );
    }
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const AuthState.signedOut();
  }
}

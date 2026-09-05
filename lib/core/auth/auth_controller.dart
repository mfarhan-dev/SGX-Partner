import 'package:flutter_riverpod/flutter_riverpod.dart';
// `AuthState`/`AuthException` collide with our own classes of the same
// name below; only `Supabase` is needed from this import.
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

import '../../shared/models/profile_summary.dart';
import 'auth_repository.dart';
import 'auth_state.dart';
import 'supabase_auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => SupabaseAuthRepository(Supabase.instance.client),
);

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState.signedOut();

  Future<void> restoreSession() async {
    state = const AuthState.checking();
    final profile = await ref.read(authRepositoryProvider).restoreSession();
    if (profile == null) {
      state = const AuthState.signedOut();
      return;
    }
    state = _stateForProfile(profile, phoneNumber: profile.phoneNumber);
  }

  Future<void> sendOtp(String phoneNumber) async {
    state = AuthState(status: AuthStatus.checking, phoneNumber: phoneNumber);
    try {
      await ref.read(authRepositoryProvider).sendOtp(phoneNumber);
      state = AuthState(status: AuthStatus.otpSent, phoneNumber: phoneNumber);
    } on AuthException catch (error) {
      state = AuthState(
        status: AuthStatus.signedOut,
        phoneNumber: phoneNumber,
        errorMessage: error.message,
      );
    }
  }

  Future<void> verifyOtp(String otp) async {
    final phoneNumber = state.phoneNumber;
    if (phoneNumber == null) return;

    state = state.copyWith(status: AuthStatus.checking);
    try {
      final profile = await ref
          .read(authRepositoryProvider)
          .verifyOtp(phoneNumber: phoneNumber, otp: otp);

      state = _stateForProfile(profile, phoneNumber: phoneNumber);
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

  AuthState _stateForProfile(
    ProfileSummary? profile, {
    required String? phoneNumber,
  }) {
    if (profile == null) {
      return AuthState(
        status: AuthStatus.signedIn,
        phoneNumber: phoneNumber,
        profile: null,
      );
    }

    if (!profile.isActive || !profile.role.isPartner) {
      return AuthState(
        status: AuthStatus.accountUnavailable,
        phoneNumber: phoneNumber,
        profile: profile,
      );
    }

    return AuthState(
      status: AuthStatus.signedIn,
      phoneNumber: phoneNumber,
      profile: profile,
    );
  }
}

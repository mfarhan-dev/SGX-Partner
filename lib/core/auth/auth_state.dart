import '../../shared/models/profile_summary.dart';

enum AuthStatus { checking, signedOut, otpSent, signedIn, accountUnavailable }

class AuthState {
  const AuthState({
    required this.status,
    this.phoneNumber,
    this.profile,
    this.errorMessage,
  });

  const AuthState.checking() : this(status: AuthStatus.checking);

  const AuthState.signedOut() : this(status: AuthStatus.signedOut);

  final AuthStatus status;
  final String? phoneNumber;
  final ProfileSummary? profile;
  final String? errorMessage;

  bool get hasVerifiedPhone => phoneNumber != null;

  AuthState copyWith({
    AuthStatus? status,
    String? phoneNumber,
    ProfileSummary? profile,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
    );
  }
}

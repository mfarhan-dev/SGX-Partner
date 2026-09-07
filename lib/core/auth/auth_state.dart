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

  AuthState copyWith({
    AuthStatus? status,
    String? phoneNumber,
    ProfileSummary? profile,
    // Nullable-but-distinguishable: omit to keep the current error,
    // pass an explicit value (including null) to replace it. Matches
    // the other fields' "preserve unless specified" semantics, unlike
    // the old version which silently cleared errorMessage on every
    // copyWith call that didn't mention it.
    Object? errorMessage = _unset,
  }) {
    return AuthState(
      status: status ?? this.status,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profile: profile ?? this.profile,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

const _unset = Object();

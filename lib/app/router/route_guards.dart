import '../../core/auth/auth_state.dart';
import '../../shared/models/app_role.dart';

class RouteGuards {
  const RouteGuards._();

  static String protectedLanding(AuthState auth) {
    final profile = auth.profile;
    if (auth.status == AuthStatus.signedOut) return '/auth/phone';
    if (auth.status == AuthStatus.accountUnavailable) {
      return '/auth/account-unavailable';
    }
    if (profile == null || !profile.isComplete) return '/mechanic/onboarding';
    if (!profile.isActive || !profile.role.isPartner) {
      return '/auth/account-unavailable';
    }
    return profile.role == AppRole.wholesaler
        ? '/wholesaler/home'
        : '/mechanic/home';
  }
}

import 'package:go_router/go_router.dart';

import '../../roles/mechanic/home/presentation/mechanic_home_screen.dart';
import '../../roles/mechanic/onboarding/presentation/complete_mechanic_profile_screen.dart';
import '../../roles/mechanic/profile/presentation/edit_mechanic_profile_screen.dart';
import '../../roles/mechanic/profile/presentation/mechanic_payout_method_screen.dart';
import '../../roles/mechanic/profile/presentation/mechanic_profile_screen.dart';
import '../../roles/mechanic/scan_history/presentation/scan_history_screen.dart';
import '../../roles/mechanic/scanner/presentation/qr_scanner_screen.dart';
import '../../roles/mechanic/wallet/presentation/mechanic_wallet_screen.dart';
import '../../roles/mechanic/withdrawals/presentation/mechanic_withdrawal_detail_screen.dart';
import '../../roles/mechanic/withdrawals/presentation/mechanic_withdrawals_screen.dart';
import '../../roles/wholesaler/home/presentation/wholesaler_home_screen.dart';
import '../../roles/wholesaler/profile/presentation/edit_wholesaler_profile_screen.dart';
import '../../roles/wholesaler/profile/presentation/wholesaler_payout_method_screen.dart';
import '../../roles/wholesaler/profile/presentation/wholesaler_profile_screen.dart';
import '../../roles/wholesaler/qr_progress/presentation/qr_progress_screen.dart';
import '../../roles/wholesaler/wallet/presentation/wholesaler_ledger_screen.dart';
import '../../roles/wholesaler/withdrawals/presentation/wholesaler_withdrawal_detail_screen.dart';
import '../../roles/wholesaler/withdrawals/presentation/wholesaler_withdrawals_screen.dart';
import '../../shared/auth/presentation/account_unavailable_screen.dart';
import '../../shared/auth/presentation/otp_verification_screen.dart';
import '../../shared/auth/presentation/phone_login_screen.dart';
import '../../shared/auth/presentation/splash_screen.dart';
import '../../shared/campaigns/presentation/campaign_detail_screen.dart';
import '../../shared/campaigns/presentation/campaigns_screen.dart';
import '../../shared/products/presentation/product_detail_screen.dart';
import '../../shared/products/presentation/products_screen.dart';
import '../shell/sgx_partners_shell.dart';

class AppRoutes {
  const AppRoutes._();

  static List<RouteBase> routes() {
    return [
      GoRoute(path: '/', redirect: (_, __) => '/splash'),
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(
        path: '/auth/phone',
        builder: (_, __) => const PhoneLoginScreen(),
      ),
      GoRoute(
        path: '/auth/otp',
        builder: (_, __) => const OtpVerificationScreen(),
      ),
      GoRoute(
        path: '/auth/account-unavailable',
        builder: (_, __) => const AccountUnavailableScreen(),
      ),
      // Outside the shell (like the /auth/* screens above): this is a
      // one-time, standalone setup step, not a destination the bottom
      // nav should ever show or let the user tab back into.
      GoRoute(
        path: '/mechanic/onboarding',
        builder: (_, __) => const CompleteMechanicProfileScreen(),
      ),
      // Same reasoning as onboarding above: a focused edit task reached
      // via the pencil icon on the profile header, not a tab the
      // bottom nav should show underneath. Back button (from its own
      // AppBar) returns to /mechanic/profile.
      GoRoute(
        path: '/mechanic/profile/edit',
        builder: (_, __) => const EditMechanicProfileScreen(),
      ),
      // Same reasoning: focused edit task, own back button, not a tab.
      GoRoute(
        path: '/wholesaler/profile/edit',
        builder: (_, __) => const EditWholesalerProfileScreen(),
      ),
      // Same reasoning again: reached from a Settings row, own back
      // button, not a tab.
      GoRoute(
        path: '/mechanic/payout-method',
        builder: (_, __) => const MechanicPayoutMethodScreen(),
      ),
      GoRoute(
        path: '/wholesaler/payout-method',
        builder: (_, __) => const WholesalerPayoutMethodScreen(),
      ),
      // Same reasoning again: reached by tapping a campaign card (or
      // "See all"), not a tab -- the bottom nav and QR FAB were
      // leaking onto both the list and the detail screen.
      GoRoute(path: '/campaigns', builder: (_, __) => const CampaignsScreen()),
      GoRoute(
        path: '/campaigns/:campaignId',
        builder: (_, state) => CampaignDetailScreen(
          campaignId: state.pathParameters['campaignId'] ?? '',
        ),
      ),
      // Same reasoning again: reached by tapping a product card, not a
      // tab -- /products (the grid) stays in the shell below since
      // that one IS a tab.
      GoRoute(
        path: '/products/:productId',
        builder: (_, state) => ProductDetailScreen(
          productId: state.pathParameters['productId'] ?? '',
        ),
      ),
      // Same reasoning again: the Withdrawals list and detail screens
      // are reached by tapping into a withdrawal, not a tab -- these
      // were incorrectly nested inside the ShellRoute below, which is
      // exactly why the bottom nav and QR FAB were leaking onto them.
      // "New request" itself is no longer a route at all -- it opens
      // as a bottom sheet straight from Home (showMechanicWithdrawMoneySheet /
      // showWholesalerWithdrawMoneySheet), since the old full screen
      // left most of its height empty.
      GoRoute(
        path: '/mechanic/withdrawals',
        builder: (_, __) => const MechanicWithdrawalsScreen(),
      ),
      GoRoute(
        path: '/mechanic/withdrawals/:withdrawalId',
        builder: (_, state) => MechanicWithdrawalDetailScreen(
          withdrawalId: state.pathParameters['withdrawalId'] ?? '',
        ),
      ),
      GoRoute(
        path: '/wholesaler/withdrawals',
        builder: (_, __) => const WholesalerWithdrawalsScreen(),
      ),
      GoRoute(
        path: '/wholesaler/withdrawals/:withdrawalId',
        builder: (_, state) => WholesalerWithdrawalDetailScreen(
          withdrawalId: state.pathParameters['withdrawalId'] ?? '',
        ),
      ),
      // Same reasoning again -- reached by tapping the shell's FAB, not
      // a tab -- and this one was the exact bug the comment above
      // already describes for Withdrawals: nested inside the ShellRoute
      // below, MechanicShell's own bottom nav bar and centered FAB sit
      // in an ancestor Scaffold that always paints above this route's
      // content, so no amount of a "hide chrome" flag on the shell can
      // reliably keep them off a full-bleed camera screen or the
      // modal sheet it opens -- moving the route out here removes the
      // shell (and the FAB/nav bar with it) from the tree entirely
      // while this screen is open, which is what every real QR
      // scanner (Uber, Venmo, ...) actually does.
      GoRoute(
        path: '/mechanic/scan',
        builder: (_, __) => const QrScannerScreen(),
      ),
      ShellRoute(
        builder: (_, __, child) => SgxPartnersShell(child: child),
        routes: [
          GoRoute(
            path: '/products',
            builder: (_, __) => const ProductsScreen(),
          ),
          GoRoute(
            path: '/mechanic/home',
            builder: (_, __) => const MechanicHomeScreen(),
          ),
          GoRoute(
            path: '/mechanic/scans',
            builder: (_, __) => const ScanHistoryScreen(),
          ),
          GoRoute(
            path: '/mechanic/wallet',
            builder: (_, __) => const MechanicWalletScreen(),
          ),
          GoRoute(
            path: '/mechanic/profile',
            builder: (_, __) => const MechanicProfileScreen(),
          ),
          GoRoute(
            path: '/wholesaler/home',
            builder: (_, __) => const WholesalerHomeScreen(),
          ),
          GoRoute(
            path: '/wholesaler/qr-progress',
            builder: (_, __) => const QrProgressScreen(),
          ),
          GoRoute(
            path: '/wholesaler/wallet',
            builder: (_, __) => const WholesalerLedgerScreen(),
          ),
          GoRoute(
            path: '/wholesaler/profile',
            builder: (_, __) => const WholesalerProfileScreen(),
          ),
        ],
      ),
    ];
  }
}

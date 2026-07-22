import 'package:go_router/go_router.dart';

import '../../roles/mechanic/home/presentation/mechanic_home_screen.dart';
import '../../roles/mechanic/onboarding/presentation/complete_mechanic_profile_screen.dart';
import '../../roles/mechanic/profile/presentation/edit_mechanic_profile_screen.dart';
import '../../roles/mechanic/profile/presentation/mechanic_profile_screen.dart';
import '../../roles/mechanic/scan_history/presentation/scan_history_screen.dart';
import '../../roles/mechanic/scanner/presentation/qr_scanner_screen.dart';
import '../../roles/mechanic/wallet/presentation/mechanic_wallet_screen.dart';
import '../../roles/mechanic/withdrawals/presentation/mechanic_withdraw_money_screen.dart';
import '../../roles/mechanic/withdrawals/presentation/mechanic_withdrawal_detail_screen.dart';
import '../../roles/mechanic/withdrawals/presentation/mechanic_withdrawals_screen.dart';
import '../../roles/wholesaler/home/presentation/wholesaler_home_screen.dart';
import '../../roles/wholesaler/profile/presentation/wholesaler_profile_screen.dart';
import '../../roles/wholesaler/qr_progress/presentation/qr_progress_screen.dart';
import '../../roles/wholesaler/wallet/presentation/wholesaler_wallet_screen.dart';
import '../../roles/wholesaler/withdrawals/presentation/wholesaler_withdraw_money_screen.dart';
import '../../roles/wholesaler/withdrawals/presentation/wholesaler_withdrawal_detail_screen.dart';
import '../../roles/wholesaler/withdrawals/presentation/wholesaler_withdrawals_screen.dart';
import '../../shared/auth/presentation/account_unavailable_screen.dart';
import '../../shared/auth/presentation/otp_verification_screen.dart';
import '../../shared/auth/presentation/phone_login_screen.dart';
import '../../shared/auth/presentation/splash_screen.dart';
import '../../shared/campaigns/presentation/campaign_detail_screen.dart';
import '../../shared/campaigns/presentation/campaigns_screen.dart';
import '../../shared/notifications/presentation/notifications_screen.dart';
import '../../shared/products/presentation/product_detail_screen.dart';
import '../../shared/products/presentation/products_screen.dart';
import '../../shared/widgets/placeholder_screen.dart';
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
      ShellRoute(
        builder: (_, __, child) => SgxPartnersShell(child: child),
        routes: [
          GoRoute(
            path: '/products',
            builder: (_, __) => const ProductsScreen(),
          ),
          GoRoute(
            path: '/products/:productId',
            builder: (_, state) => ProductDetailScreen(
              productId: state.pathParameters['productId'] ?? '',
            ),
          ),
          GoRoute(
            path: '/campaigns',
            builder: (_, __) => const CampaignsScreen(),
          ),
          GoRoute(
            path: '/campaigns/:campaignId',
            builder: (_, state) => CampaignDetailScreen(
              campaignId: state.pathParameters['campaignId'] ?? '',
            ),
          ),
          GoRoute(
            path: '/notifications',
            builder: (_, __) => const NotificationsScreen(),
          ),
          GoRoute(
            path: '/profile/preferences',
            builder: (_, __) => const PlaceholderScreen(
              title: 'Preferences',
              description: 'Theme and language preferences placeholder.',
            ),
          ),
          GoRoute(
            path: '/mechanic/onboarding',
            builder: (_, __) => const CompleteMechanicProfileScreen(),
          ),
          GoRoute(
            path: '/mechanic/home',
            builder: (_, __) => const MechanicHomeScreen(),
          ),
          GoRoute(
            path: '/mechanic/scan',
            builder: (_, __) => const QrScannerScreen(),
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
            path: '/mechanic/withdrawals',
            builder: (_, __) => const MechanicWithdrawalsScreen(),
          ),
          GoRoute(
            path: '/mechanic/withdrawals/new',
            builder: (_, __) => const MechanicWithdrawMoneyScreen(),
          ),
          GoRoute(
            path: '/mechanic/withdrawals/:withdrawalId',
            builder: (_, state) => MechanicWithdrawalDetailScreen(
              withdrawalId: state.pathParameters['withdrawalId'] ?? '',
            ),
          ),
          GoRoute(
            path: '/mechanic/profile',
            builder: (_, __) => const MechanicProfileScreen(),
          ),
          GoRoute(
            path: '/mechanic/profile/edit',
            builder: (_, __) => const EditMechanicProfileScreen(),
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
            builder: (_, __) => const WholesalerWalletScreen(),
          ),
          GoRoute(
            path: '/wholesaler/withdrawals',
            builder: (_, __) => const WholesalerWithdrawalsScreen(),
          ),
          GoRoute(
            path: '/wholesaler/withdrawals/new',
            builder: (_, __) => const WholesalerWithdrawMoneyScreen(),
          ),
          GoRoute(
            path: '/wholesaler/withdrawals/:withdrawalId',
            builder: (_, state) => WholesalerWithdrawalDetailScreen(
              withdrawalId: state.pathParameters['withdrawalId'] ?? '',
            ),
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

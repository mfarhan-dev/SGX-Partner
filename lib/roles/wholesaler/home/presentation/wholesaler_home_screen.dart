import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/mock/sgx_mock_data.dart';
import '../../../../shared/models/money_amount.dart';
import '../../../../shared/widgets/partner_greeting.dart';
import '../../../../shared/widgets/sgx_cards.dart';
import '../../profile/data/wholesaler_profile_providers.dart';

class WholesalerHomeScreen extends ConsumerWidget {
  const WholesalerHomeScreen({super.key});

  static const _availableBalance = MoneyAmount(cents: 1842000);
  static const _activeWithdrawal = MockWithdrawal(
    id: 'wd-001',
    amount: MoneyAmount(cents: 500000),
    method: 'JazzCash',
    date: 'Sent today',
    status: 'Payment Sent',
    note: 'Please confirm after checking your balance.',
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Same wholesalerProfileDataProvider Settings already fetches once
    // per session -- reused here so Home shows the real signed-in
    // person instead of the old hardcoded "Muhammad Farhan" mock.
    final profileAsync = ref.watch(wholesalerProfileDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: profileAsync.when(
          data: (profile) => PartnerGreeting(
            name: profile.ownerName,
            photoUrl: profile.photoUrl,
          ),
          loading: () => const PartnerGreetingSkeleton(),
          // A failed fetch here shouldn't block the whole Home screen
          // the way it would on Settings -- fall back to a neutral
          // greeting instead of an error banner over the wallet.
          error: (error, stackTrace) => const PartnerGreeting(name: 'Partner'),
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => context.push('/notifications'),
            icon: const Badge(
              label: Text('3'),
              child: Icon(Icons.notifications_outlined),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            WalletHeroCard(
              available: _availableBalance,
              pending: const MoneyAmount(cents: 500000),
              lifetime: const MoneyAmount(cents: 14234000),
              onWithdraw: () => context.go('/wholesaler/withdrawals/new'),
              compact: true,
            ),
            const SizedBox(height: AppSpacing.md),
            const WithdrawalStatusCard(
              withdrawal: _activeWithdrawal,
              routePrefix: '/wholesaler/withdrawals',
              availableBalance: _availableBalance,
            ),
            const SizedBox(height: AppSpacing.md),
            CampaignTile(campaign: mockCampaigns.last),
          ],
        ),
      ),
    );
  }
}

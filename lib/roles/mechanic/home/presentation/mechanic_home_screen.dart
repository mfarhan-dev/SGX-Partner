import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/mock/sgx_mock_data.dart';
import '../../../../shared/models/money_amount.dart';
import '../../../../shared/widgets/partner_greeting.dart';
import '../../../../shared/widgets/sgx_cards.dart';
import '../../profile/data/mechanic_profile_providers.dart';

class MechanicHomeScreen extends ConsumerWidget {
  const MechanicHomeScreen({super.key});

  static const _availableBalance = MoneyAmount(cents: 428500);
  static const _activeWithdrawal = MockWithdrawal(
    id: 'wd-001',
    amount: MoneyAmount(cents: 150000),
    method: 'JazzCash',
    date: 'Submitted today',
    status: 'Pending',
    note: 'SGX is reviewing the request. No action is required right now.',
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Same mechanicProfileDataProvider Settings already fetches once
    // per session -- reused here so Home shows the real signed-in
    // person instead of the old hardcoded "Muhammad Farhan" mock.
    final profileAsync = ref.watch(mechanicProfileDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: profileAsync.when(
          data: (profile) => PartnerGreeting(
            name: profile.fullName,
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
              pending: const MoneyAmount(cents: 150000),
              lifetime: const MoneyAmount(cents: 2854000),
              compact: true,
              onWithdraw: () => context.go('/mechanic/withdrawals/new'),
            ),
            const SizedBox(height: AppSpacing.md),
            const WithdrawalStatusCard(
              withdrawal: _activeWithdrawal,
              routePrefix: '/mechanic/withdrawals',
              availableBalance: _availableBalance,
            ),
            const SizedBox(height: AppSpacing.md),
            CampaignTile(campaign: mockCampaigns.first),
          ],
        ),
      ),
    );
  }
}

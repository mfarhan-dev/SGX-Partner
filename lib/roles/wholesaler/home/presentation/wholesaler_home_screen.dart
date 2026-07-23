import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/mock/sgx_mock_data.dart';
import '../../../../shared/models/money_amount.dart';
import '../../../../shared/widgets/sgx_cards.dart';

class WholesalerHomeScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(radius: 20, child: Text('MF')),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Assalam-o-Alaikum',
                    style: TextStyle(fontSize: 12, color: AppColors.mutedText),
                  ),
                  Text(
                    'Muhammad Farhan',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ],
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

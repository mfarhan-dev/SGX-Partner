import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/mock/sgx_mock_data.dart';
import '../../../../shared/models/money_amount.dart';
import '../../../../shared/widgets/sgx_cards.dart';

class MechanicHomeScreen extends StatelessWidget {
  const MechanicHomeScreen({super.key});

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
              available: const MoneyAmount(cents: 428500),
              pending: const MoneyAmount(cents: 150000),
              lifetime: const MoneyAmount(cents: 2854000),
              compact: true,
              onWithdraw: () => context.go('/mechanic/withdrawals/new'),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Text(
                  'Latest scan',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.go('/mechanic/scans'),
                  child: const Text('History'),
                ),
              ],
            ),
            TransactionRow(
              transaction: MockTransaction(
                title: 'Shell Advance AX7',
                subtitle: 'Today · 10:24 AM',
                amount: const MoneyAmount(cents: 1500),
                icon: Icons.oil_barrel_outlined,
                tone: AppColors.success,
                status: 'Confirmed',
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Card(
              color: AppColors.warningContainer,
              child: ListTile(
                onTap: () => context.go('/mechanic/withdrawals/wd-001'),
                leading: const Icon(Icons.schedule, color: AppColors.warning),
                title: const Text('Withdrawal in progress'),
                subtitle: const Text('Rs. 1,500 · JazzCash · Submitted today'),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            CampaignTile(campaign: mockCampaigns.first),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/mock/sgx_mock_data.dart';
import '../../../../shared/models/money_amount.dart';
import '../../../../shared/widgets/sgx_app_bar.dart';
import '../../../../shared/widgets/sgx_cards.dart';

class WholesalerHomeScreen extends StatelessWidget {
  const WholesalerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SgxAppBar(
        title: 'SGX Partners',
        showBrand: true,
        showNotifications: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Text(
              'Assalam-o-Alaikum,',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
            ),
            Text(
              'Muhammad Farhan',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            const Chip(
              avatar: Icon(Icons.storefront, size: 16),
              label: Text('Farhan Motor Parts · Lahore'),
            ),
            const SizedBox(height: AppSpacing.md),
            WalletHeroCard(
              available: const MoneyAmount(cents: 1842000),
              pending: const MoneyAmount(cents: 500000),
              lifetime: const MoneyAmount(cents: 14234000),
              onWithdraw: () => context.go('/wholesaler/withdrawals/new'),
              compact: true,
            ),
            const SizedBox(height: AppSpacing.md),
            Card(
              color: AppColors.surfaceContainer,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'QR Progress',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () =>
                              context.go('/wholesaler/qr-progress'),
                          child: const Text('View all'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '486',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(width: 4),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 6),
                          child: Text('/ 720 scanned'),
                        ),
                        const Spacer(),
                        const Text(
                          '67%',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const LinearProgressIndicator(value: 0.67, minHeight: 10),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TransactionRow(transaction: wholesalerTransactions.first),
            Card(
              color: AppColors.warningContainer,
              child: ListTile(
                onTap: () => context.go('/wholesaler/withdrawals/wd-001'),
                leading: const Icon(Icons.schedule, color: AppColors.warning),
                title: const Text('Payment sent — please confirm'),
                subtitle: const Text('Rs. 5,000 · JazzCash · Today'),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            CampaignTile(campaign: mockCampaigns.last),
            const SizedBox(height: AppSpacing.md),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.2,
              children: [
                _QuickAction(
                  label: 'QR Progress',
                  icon: Icons.qr_code_2_outlined,
                  onTap: () => context.go('/wholesaler/qr-progress'),
                ),
                _QuickAction(
                  label: 'Wallet',
                  icon: Icons.account_balance_wallet_outlined,
                  onTap: () => context.go('/wholesaler/wallet'),
                ),
                _QuickAction(
                  label: 'Withdraw',
                  icon: Icons.payments_outlined,
                  onTap: () => context.go('/wholesaler/withdrawals/new'),
                ),
                _QuickAction(
                  label: 'Products',
                  icon: Icons.category_outlined,
                  onTap: () => context.go('/products'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(label)),
            ],
          ),
        ),
      ),
    );
  }
}

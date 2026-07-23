import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/mock/sgx_mock_data.dart';
import '../../../../shared/models/money_amount.dart';
import '../../../../shared/widgets/sgx_cards.dart';
import '../../../../shared/widgets/sgx_screen.dart';

class WholesalerWalletScreen extends StatelessWidget {
  const WholesalerWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SgxScreen(
      title: 'Wallet',
      showNotifications: true,
      children: [
        WalletHeroCard(
          available: const MoneyAmount(cents: 1842000),
          pending: const MoneyAmount(cents: 500000),
          lifetime: const MoneyAmount(cents: 14234000),
          onWithdraw: () => context.go('/wholesaler/withdrawals/new'),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => context.go('/wholesaler/withdrawals/new'),
                icon: const Icon(Icons.payments_outlined),
                label: const Text('Withdraw Money'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton.outlined(
              onPressed: () => context.go('/wholesaler/withdrawals'),
              icon: const Icon(Icons.receipt_long),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        const Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: AppColors.mutedText),
            SizedBox(width: 6),
            Text('Minimum withdrawal is Rs. 500.'),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text('Recent activity', style: Theme.of(context).textTheme.titleMedium),
        ...wholesalerTransactions.map(
          (transaction) => TransactionRow(transaction: transaction),
        ),
      ],
    );
  }
}

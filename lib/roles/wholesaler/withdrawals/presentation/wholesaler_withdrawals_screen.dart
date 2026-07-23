import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/mock/sgx_mock_data.dart';
import '../../../../shared/widgets/sgx_cards.dart';
import '../../../../shared/widgets/sgx_screen.dart';

class WholesalerWithdrawalsScreen extends StatelessWidget {
  const WholesalerWithdrawalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SgxScreen(
      title: 'Withdrawals',
      showBack: true,
      showNotifications: false,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          children: const [
            ChoiceChip(label: Text('All (6)'), selected: true),
            ChoiceChip(label: Text('Open (3)'), selected: false),
            ChoiceChip(label: Text('Completed (3)'), selected: false),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ...mockWithdrawals.map(
          (withdrawal) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: WithdrawalCard(
              withdrawal: withdrawal,
              routePrefix: '/wholesaler/withdrawals',
            ),
          ),
        ),
      ],
    );
  }
}

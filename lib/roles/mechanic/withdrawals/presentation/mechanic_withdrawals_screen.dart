import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/mock/sgx_mock_data.dart';
import '../../../../shared/widgets/sgx_cards.dart';
import '../../../../shared/widgets/sgx_screen.dart';

class MechanicWithdrawalsScreen extends StatelessWidget {
  const MechanicWithdrawalsScreen({super.key});

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
            ChoiceChip(label: Text('All'), selected: true),
            ChoiceChip(label: Text('Open'), selected: false),
            ChoiceChip(label: Text('Completed'), selected: false),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ...mockWithdrawals.map(
          (withdrawal) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: WithdrawalCard(
              withdrawal: withdrawal,
              routePrefix: '/mechanic/withdrawals',
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/sgx_cards.dart';
import '../../../../shared/widgets/sgx_screen.dart';
import '../../../../shared/withdrawals/data/withdrawals_providers.dart';

enum _Filter { all, open, completed }

class WholesalerWithdrawalsScreen extends ConsumerStatefulWidget {
  const WholesalerWithdrawalsScreen({super.key});

  @override
  ConsumerState<WholesalerWithdrawalsScreen> createState() =>
      _WholesalerWithdrawalsScreenState();
}

class _WholesalerWithdrawalsScreenState
    extends ConsumerState<WholesalerWithdrawalsScreen> {
  _Filter _filter = _Filter.all;

  @override
  Widget build(BuildContext context) {
    final withdrawalsAsync = ref.watch(withdrawalsListProvider);

    return SgxScreen(
      title: 'Withdrawals',
      showBack: true,
      showNotifications: false,
      children: [
        withdrawalsAsync.when(
          data: (withdrawals) {
            final open = withdrawals.where((w) => !w.status.isTerminal).length;
            final completed = withdrawals.length - open;
            final filtered = withdrawals.where((w) {
              return switch (_filter) {
                _Filter.all => true,
                _Filter.open => !w.status.isTerminal,
                _Filter.completed => w.status.isTerminal,
              };
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpacing.sm,
                  children: [
                    ChoiceChip(
                      label: Text('All (${withdrawals.length})'),
                      selected: _filter == _Filter.all,
                      onSelected: (_) => setState(() => _filter = _Filter.all),
                    ),
                    ChoiceChip(
                      label: Text('Open ($open)'),
                      selected: _filter == _Filter.open,
                      onSelected: (_) => setState(() => _filter = _Filter.open),
                    ),
                    ChoiceChip(
                      label: Text('Completed ($completed)'),
                      selected: _filter == _Filter.completed,
                      onSelected: (_) =>
                          setState(() => _filter = _Filter.completed),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: Text(
                        withdrawals.isEmpty
                            ? 'You have not requested a withdrawal yet.'
                            : 'Nothing in this filter.',
                        style: TextStyle(color: AppColors.mutedTextOf(context)),
                      ),
                    ),
                  )
                else
                  ...filtered.map(
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
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 64),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stackTrace) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 64),
            child: Center(
              child: Text(
                'Could not load your withdrawals.',
                style: TextStyle(color: AppColors.mutedTextOf(context)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

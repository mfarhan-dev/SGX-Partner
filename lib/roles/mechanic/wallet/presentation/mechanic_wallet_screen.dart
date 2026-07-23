import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/mock/sgx_mock_data.dart';
import '../../../../shared/widgets/sgx_cards.dart';
import '../../../../shared/widgets/sgx_screen.dart';

enum _ActivityFilter { all, rewards, withdraw, pending }

class MechanicWalletScreen extends StatefulWidget {
  const MechanicWalletScreen({super.key});

  @override
  State<MechanicWalletScreen> createState() => _MechanicWalletScreenState();
}

class _MechanicWalletScreenState extends State<MechanicWalletScreen> {
  _ActivityFilter _filter = _ActivityFilter.all;

  @override
  Widget build(BuildContext context) {
    final transactions = mechanicTransactions.where(_matchesFilter).toList();

    return SgxScreen(
      title: 'Recent Activity',
      showNotifications: false,
      children: [
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: _ActivityFilter.values.map((filter) {
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: ChoiceChip(
                  label: Text(_labelFor(filter)),
                  selected: _filter == filter,
                  onSelected: (_) => setState(() => _filter = filter),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...transactions.map(
          (transaction) => TransactionRow(transaction: transaction),
        ),
        if (transactions.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xl),
            child: Center(
              child: Text(
                'No activity found',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
      ],
    );
  }

  bool _matchesFilter(MockTransaction transaction) {
    return switch (_filter) {
      _ActivityFilter.all => true,
      _ActivityFilter.rewards => transaction.amount.cents > 0,
      _ActivityFilter.withdraw => transaction.amount.cents < 0,
      _ActivityFilter.pending => transaction.status == 'Pending',
    };
  }

  String _labelFor(_ActivityFilter filter) {
    return switch (filter) {
      _ActivityFilter.all => 'All',
      _ActivityFilter.rewards => 'Rewards',
      _ActivityFilter.withdraw => 'Withdraw',
      _ActivityFilter.pending => 'Pending',
    };
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/sgx_screen.dart';

class MechanicWithdrawMoneyScreen extends StatelessWidget {
  const MechanicWithdrawMoneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SgxScreen(
      title: 'Withdraw Money',
      showBack: true,
      showNotifications: false,
      children: [
        _BalanceBanner(amount: 'Rs. 4,285'),
        const SizedBox(height: AppSpacing.md),
        TextField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            prefixText: 'Rs. ',
            labelText: 'How much?',
            hintText: '500',
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          children: const [
            ActionChip(label: Text('Rs. 500')),
            ActionChip(label: Text('Rs. 1,000')),
            ActionChip(label: Text('Rs. 2,000')),
            ActionChip(label: Text('All')),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Payment method', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        const _MethodCard(
          title: 'EasyPaisa',
          subtitle: 'Mobile wallet',
          icon: Icons.phone_android,
          selected: true,
        ),
        const _MethodCard(
          title: 'JazzCash',
          subtitle: 'Mobile wallet',
          icon: Icons.phone_android,
        ),
        const _MethodCard(
          title: 'Bank Transfer',
          subtitle: 'Account or IBAN',
          icon: Icons.account_balance_outlined,
        ),
        const _MethodCard(
          title: 'Cash from SGX',
          subtitle: 'Collect from SGX',
          icon: Icons.store_outlined,
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(decoration: InputDecoration(labelText: 'Account Title *')),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          keyboardType: TextInputType.phone,
          maxLength: 11,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
          ],
          decoration: const InputDecoration(
            labelText: 'Mobile Number *',
            hintText: '03001234567',
            counterText: '',
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        FilledButton.icon(
          onPressed: () => _confirm(context),
          icon: const Icon(Icons.arrow_forward),
          label: const Text('Continue'),
        ),
      ],
    );
  }

  void _confirm(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Confirm withdrawal',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Rs. 1,000',
              style: Theme.of(
                context,
              ).textTheme.displaySmall?.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.md),
            const ListTile(
              leading: Icon(Icons.phone_android),
              title: Text('EasyPaisa'),
              subtitle: Text('Muhammad Farhan · 0300-***4567'),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: () => context.go('/mechanic/withdrawals/wd-001'),
                    icon: const Icon(Icons.check),
                    label: const Text('Confirm Withdrawal'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceBanner extends StatelessWidget {
  const _BalanceBanner({required this.amount});

  final String amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_balance_wallet, color: Colors.white),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Available Balance\n$amount',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const Text('Min Rs. 500', style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.selected = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.outline,
          width: selected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_off,
        ),
      ),
    );
  }
}

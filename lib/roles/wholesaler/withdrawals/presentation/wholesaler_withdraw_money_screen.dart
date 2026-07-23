import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/sgx_screen.dart';

class WholesalerWithdrawMoneyScreen extends StatelessWidget {
  const WholesalerWithdrawMoneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SgxScreen(
      title: 'Withdraw Money',
      showBack: true,
      showNotifications: false,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            children: [
              Icon(Icons.account_balance_wallet, color: Colors.white),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Available Balance\nRs. 18,420',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text('Minimum Rs. 500', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          decoration: const InputDecoration(
            labelText: 'How much?',
            prefixText: 'Rs. ',
            icon: Icon(Icons.payments_outlined),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          children: const [
            ActionChip(label: Text('Rs. 500')),
            ActionChip(label: Text('Rs. 1,000')),
            ActionChip(label: Text('Rs. 5,000')),
            ActionChip(label: Text('All (Rs. 18,420)')),
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
          onPressed: () => context.go('/wholesaler/withdrawals/wd-001'),
          icon: const Icon(Icons.arrow_forward),
          label: const Text('Continue'),
        ),
      ],
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

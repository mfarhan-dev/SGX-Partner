import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/sgx_screen.dart';

class WholesalerWithdrawalDetailScreen extends StatelessWidget {
  const WholesalerWithdrawalDetailScreen({
    super.key,
    required this.withdrawalId,
  });

  final String withdrawalId;

  @override
  Widget build(BuildContext context) {
    return SgxScreen(
      title: 'Withdrawal Detail',
      showBack: true,
      showNotifications: false,
      children: [
        Center(
          child: Column(
            children: [
              const Text('Withdrawal amount'),
              Text(
                'Rs. 5,000',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const Chip(
                avatar: Icon(Icons.send, size: 16),
                label: Text('Payment Sent'),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text('JazzCash · 0300-***4567'),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Card(
          color: AppColors.surfaceContainer,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Text(
                  'Did you receive Rs. 5,000?',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'If you do not respond within 3 days, this payment will be auto-confirmed.',
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        child: const Text('Not Received'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: () {},
                        child: const Text('Yes, Received'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const _TimelineStep(
          done: true,
          title: 'Submitted',
          note: 'Today · 10:20 AM',
        ),
        const _TimelineStep(
          done: true,
          title: 'Payment sent by SGX',
          note: 'Reference JC-8827145',
        ),
        const _TimelineStep(
          done: false,
          title: 'Payment confirmation',
          note: 'Waiting for your response',
        ),
      ],
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.done,
    required this.title,
    required this.note,
  });

  final bool done;
  final String title;
  final String note;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: done ? AppColors.primary : AppColors.surfaceContainer,
        child: Icon(
          done ? Icons.check : Icons.circle_outlined,
          color: done ? Colors.white : AppColors.mutedText,
        ),
      ),
      title: Text(title),
      subtitle: Text(note),
    );
  }
}

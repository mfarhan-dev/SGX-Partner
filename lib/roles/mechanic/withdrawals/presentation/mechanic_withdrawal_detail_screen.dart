import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/sgx_screen.dart';

class MechanicWithdrawalDetailScreen extends StatelessWidget {
  const MechanicWithdrawalDetailScreen({super.key, required this.withdrawalId});

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
              const Chip(
                avatar: Icon(Icons.send, size: 16),
                label: Text('Payment Sent'),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Rs. 5,000',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const Text('JazzCash · Sent today'),
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
                  'Did you receive this payment?',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text('Please check your JazzCash balance and confirm.'),
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
                      child: FilledButton(
                        onPressed: () {},
                        child: const Text('Received'),
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
          title: 'Withdrawal requested',
          note: 'Today · 10:20 AM',
        ),
        const _TimelineStep(
          done: true,
          title: 'Payment sent by SGX',
          note: 'Today · 12:05 PM',
        ),
        const _TimelineStep(
          done: false,
          title: 'Waiting for your confirmation',
          note: 'Auto-confirms in 3 days',
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.support_agent),
          label: const Text('Contact SGX on WhatsApp'),
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
        backgroundColor: done ? AppColors.success : AppColors.surfaceContainer,
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

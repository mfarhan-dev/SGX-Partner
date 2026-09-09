import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../shared/widgets/sgx_screen.dart';
import '../../../../shared/withdrawals/data/withdrawals_providers.dart';
import '../../../../shared/withdrawals/domain/withdrawal.dart';
import '../../../../shared/withdrawals/domain/withdrawal_status.dart';
import '../../profile/data/mechanic_profile_providers.dart';

class MechanicWithdrawalDetailScreen extends ConsumerWidget {
  const MechanicWithdrawalDetailScreen({super.key, required this.withdrawalId});

  final String withdrawalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final withdrawalAsync = ref.watch(withdrawalDetailProvider(withdrawalId));

    return SgxScreen(
      title: 'Withdrawal Detail',
      showBack: true,
      showNotifications: false,
      children: [
        withdrawalAsync.when(
          data: (withdrawal) => _WithdrawalDetailBody(withdrawal: withdrawal),
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 64),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stackTrace) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 64),
            child: Center(
              child: Text(
                'Could not load this withdrawal.',
                style: TextStyle(color: AppColors.mutedTextOf(context)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WithdrawalDetailBody extends ConsumerStatefulWidget {
  const _WithdrawalDetailBody({required this.withdrawal});

  final Withdrawal withdrawal;

  @override
  ConsumerState<_WithdrawalDetailBody> createState() =>
      _WithdrawalDetailBodyState();
}

class _WithdrawalDetailBodyState extends ConsumerState<_WithdrawalDetailBody> {
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final withdrawal = widget.withdrawal;
    final status = withdrawal.status;
    final awaitingConfirmation = status == WithdrawalStatus.paymentSent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              Chip(
                avatar: Icon(_statusIcon(status), size: 16),
                label: Text(status.label),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                MoneyFormatter.format(withdrawal.amount),
                style: Theme.of(context).textTheme.displaySmall,
              ),
              Text('${withdrawal.method.label} · ${withdrawal.withdrawalNo}'),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (awaitingConfirmation)
          Card(
            color: AppColors.surfaceContainerOf(context),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  Text(
                    'Did you receive this payment?',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Please check your ${withdrawal.method.label} balance and confirm.',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _submitting ? null : _disputeReceived,
                          child: const Text('Not Received'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: FilledButton(
                          onPressed: _submitting ? null : _confirmReceived,
                          child: _submitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Received'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        else if (status == WithdrawalStatus.disputed)
          Card(
            color: AppColors.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Under review',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    withdrawal.disputeReason ??
                        'SGX is investigating this payment.',
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        _TimelineStep(
          done: true,
          title: 'Withdrawal requested',
          note: _formatTimestamp(withdrawal.requestedAt),
        ),
        _TimelineStep(
          done: withdrawal.paymentSentAt != null,
          title: 'Payment sent by SGX',
          note: withdrawal.paymentSentAt != null
              ? _formatTimestamp(withdrawal.paymentSentAt!)
              : 'Waiting for SGX to send payment',
        ),
        _TimelineStep(
          done: status.isTerminal,
          title: switch (status) {
            WithdrawalStatus.disputed => 'Under review by SGX',
            WithdrawalStatus.refunded => 'Refunded to your balance',
            _ => 'Your confirmation',
          },
          note: withdrawal.confirmedAt != null
              ? _formatTimestamp(withdrawal.confirmedAt!)
              : awaitingConfirmation
              ? 'Waiting for your response'
              : 'Not yet reached',
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

  Future<void> _confirmReceived() async {
    setState(() => _submitting = true);
    try {
      await ref
          .read(withdrawalsRepositoryProvider)
          .confirmReceived(widget.withdrawal.id);
      ref.invalidate(withdrawalDetailProvider(widget.withdrawal.id));
      ref.invalidate(withdrawalsListProvider);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not confirm. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _disputeReceived() async {
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => _DisputeReasonDialog(),
    );
    if (reason == null) return;

    setState(() => _submitting = true);
    try {
      await ref
          .read(withdrawalsRepositoryProvider)
          .disputeReceived(widget.withdrawal.id, reason);
      ref.invalidate(withdrawalDetailProvider(widget.withdrawal.id));
      ref.invalidate(withdrawalsListProvider);
      // The reserved balance stays deducted while a dispute is under
      // review (per how request_withdrawal() reserves it) -- no
      // profile refetch needed here, only on refund.
      ref.invalidate(mechanicProfileDataProvider);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not submit. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  IconData _statusIcon(WithdrawalStatus status) => switch (status) {
    WithdrawalStatus.paymentSent => Icons.send,
    WithdrawalStatus.confirmed ||
    WithdrawalStatus.autoConfirmed => Icons.check_circle,
    WithdrawalStatus.disputed => Icons.error,
    WithdrawalStatus.refunded => Icons.replay,
    WithdrawalStatus.pending => Icons.schedule,
  };

  String _formatTimestamp(DateTime dateTime) =>
      DateFormat('d MMM, h:mm a').format(dateTime.toLocal());
}

class _DisputeReasonDialog extends StatefulWidget {
  @override
  State<_DisputeReasonDialog> createState() => _DisputeReasonDialogState();
}

class _DisputeReasonDialogState extends State<_DisputeReasonDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('What went wrong?'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLines: 3,
        decoration: const InputDecoration(
          hintText: 'e.g. Amount not received in my JazzCash account',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final reason = _controller.text.trim();
            Navigator.pop(
              context,
              reason.isEmpty ? 'Payment not received' : reason,
            );
          },
          child: const Text('Submit'),
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
        backgroundColor: done
            ? AppColors.success
            : AppColors.surfaceContainerOf(context),
        child: Icon(
          done ? Icons.check : Icons.circle_outlined,
          color: done ? Colors.white : AppColors.mutedTextOf(context),
        ),
      ),
      title: Text(title),
      subtitle: Text(note),
    );
  }
}

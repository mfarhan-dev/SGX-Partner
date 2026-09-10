import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/shell/bottom_chrome_visibility.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../shared/models/money_amount.dart';
import '../../../../shared/withdrawals/data/withdrawals_providers.dart';
import '../../../../shared/withdrawals/domain/withdrawal_method.dart';
import '../../profile/data/wholesaler_profile_providers.dart';

/// Opens the real request_withdrawal() form as a bottom sheet -- "Quiet
/// Ledger" design: a proper close button instead of relying on the
/// drag handle alone, the amount field defaults to the full available
/// balance (no separate "All" button). Payout method is never set up
/// or changed here -- Settings > Payout Method is the one place that
/// happens, matching the "don't collect account details twice" rule.
/// This sheet only ever shows the single already-saved method, or an
/// "Add payout account" row when nothing is saved yet.
///
/// The shell's own bottom nav bar (WholesalerShell) occupies this
/// exact same screen region, so it's told to hide for the sheet's
/// lifetime via bottomChromeHiddenProvider -- restored the instant the
/// sheet closes, whether by the close button, a swipe, or a
/// successful submit. Home's own content behind the sheet keeps the
/// normal Material scrim; only the nav chrome disappears.
Future<void> showWholesalerWithdrawMoneySheet(
  BuildContext context,
  WidgetRef ref,
) async {
  ref.read(bottomChromeHiddenProvider.notifier).set(true);
  try {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => const _WholesalerWithdrawMoneySheet(),
    );
  } finally {
    ref.read(bottomChromeHiddenProvider.notifier).set(false);
  }
}

class _WholesalerWithdrawMoneySheet extends ConsumerStatefulWidget {
  const _WholesalerWithdrawMoneySheet();

  @override
  ConsumerState<_WholesalerWithdrawMoneySheet> createState() =>
      _WholesalerWithdrawMoneySheetState();
}

class _WholesalerWithdrawMoneySheetState
    extends ConsumerState<_WholesalerWithdrawMoneySheet> {
  final _amountController = TextEditingController();
  bool _submitting = false;
  String? _error;
  bool _prefilled = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(wholesalerProfileDataProvider);
    final minAmountAsync = ref.watch(minWithdrawalAmountProvider);
    final profile = profileAsync.value;
    final available = profile?.pointsBalance ?? 0;
    final minAmount = minAmountAsync.value;
    final payoutMethod = profile?.payoutMethod;

    // Full balance by default (editable) once the real profile arrives.
    if (!_prefilled && profile != null) {
      _prefilled = true;
      _amountController.text = available > 0 ? '$available' : '';
    }

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Withdraw money',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      minAmount == null
                          ? '${MoneyFormatter.format(MoneyAmount(cents: available * 100))} available'
                          : '${MoneyFormatter.format(MoneyAmount(cents: available * 100))} available · '
                                'Rs. $minAmount minimum',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedTextOf(context),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Close',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surfaceContainerOf(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
            decoration: const InputDecoration(
              prefixText: 'Rs. ',
              labelText: 'How much?',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _PayoutSummary(
            method: payoutMethod,
            onManage: () => _openPayoutSettings(context),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(_error!, style: const TextStyle(color: AppColors.error)),
          ],
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onPressed:
                  _submitting ||
                      minAmount == null ||
                      profile == null ||
                      payoutMethod == null
                  ? null
                  : () => _confirm(context, available, minAmount, payoutMethod),
              icon: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.arrow_forward),
              label: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }

  void _openPayoutSettings(BuildContext context) {
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    router.push('/wholesaler/payout-method');
  }

  void _confirm(
    BuildContext context,
    int available,
    int minAmount,
    WithdrawalMethod method,
  ) {
    final amount = int.tryParse(_amountController.text);

    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter how much you want to withdraw.');
      return;
    }
    if (amount < minAmount) {
      setState(
        () => _error =
            'Minimum withdrawal amount is ${MoneyFormatter.format(MoneyAmount(cents: minAmount * 100))}.',
      );
      return;
    }
    if (amount > available) {
      setState(() => _error = 'That is more than your available balance.');
      return;
    }
    setState(() => _error = null);

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm withdrawal'),
        content: Text(
          'Withdraw ${MoneyFormatter.format(MoneyAmount(cents: amount * 100))} '
          'via ${method.label}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => _submit(dialogContext, amount),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext dialogContext, int amount) async {
    setState(() => _submitting = true);
    try {
      final withdrawal = await ref
          .read(withdrawalsRepositoryProvider)
          .createWithdrawal(amountRupees: amount);

      // Balance was just deducted server-side -- refetch both so Home
      // and this list reflect it immediately instead of on next app
      // launch.
      ref.invalidate(wholesalerProfileDataProvider);
      ref.invalidate(withdrawalsListProvider);

      if (!dialogContext.mounted) return;
      Navigator.pop(dialogContext);
      if (!mounted) return;
      Navigator.of(context).pop();
      if (!context.mounted) return;
      context.push('/wholesaler/withdrawals/${withdrawal.id}');
    } catch (error) {
      if (!dialogContext.mounted) return;
      Navigator.pop(dialogContext);
      setState(() {
        _submitting = false;
        _error = 'Could not submit the request. Please try again.';
      });
    }
  }
}

/// Either the one payout method already saved in Settings, or a call
/// to go set one up -- this sheet never collects account details
/// itself, so there's nothing to pick between here.
class _PayoutSummary extends StatelessWidget {
  const _PayoutSummary({required this.method, required this.onManage});

  final WithdrawalMethod? method;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    if (method == null) {
      // Tonal card, not an OutlinedButton -- Material 3's own guidance
      // reserves outlined buttons for a lower-emphasis, secondary
      // action. Setting up a payout method is the one thing actually
      // blocking this screen, so it gets the higher-emphasis filled
      // treatment instead ("Variant 01" from the design exploration).
      return InkWell(
        onTap: onManage,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.errorContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add payout account',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    Text(
                      'Required before you can withdraw',
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(color: AppColors.error),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.error),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerOf(context),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            method == WithdrawalMethod.bankTransfer
                ? Icons.account_balance_outlined
                : Icons.phone_android,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Paying to ${method!.label}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          TextButton(onPressed: onManage, child: const Text('Change')),
        ],
      ),
    );
  }
}

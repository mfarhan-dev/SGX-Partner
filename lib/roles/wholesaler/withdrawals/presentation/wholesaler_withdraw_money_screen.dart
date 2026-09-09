import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../shared/models/money_amount.dart';
import '../../../../shared/widgets/sgx_screen.dart';
import '../../../../shared/withdrawals/data/withdrawals_providers.dart';
import '../../../../shared/withdrawals/domain/withdrawal_method.dart';
import '../../profile/data/wholesaler_profile_providers.dart';

/// Real request_withdrawal() form -- replaces the fully decorative
/// mock. Amount/method/account fields are validated client-side for a
/// fast error message, but the RPC re-validates all of it server-side
/// (minimum amount, sufficient balance) since that's the only source
/// of truth that can't be raced or spoofed.
class WholesalerWithdrawMoneyScreen extends ConsumerStatefulWidget {
  const WholesalerWithdrawMoneyScreen({super.key});

  @override
  ConsumerState<WholesalerWithdrawMoneyScreen> createState() =>
      _WholesalerWithdrawMoneyScreenState();
}

class _WholesalerWithdrawMoneyScreenState
    extends ConsumerState<WholesalerWithdrawMoneyScreen> {
  final _amountController = TextEditingController();
  final _accountTitleController = TextEditingController();
  final _accountNumberController = TextEditingController();
  WithdrawalMethod _method = WithdrawalMethod.easyPaisa;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _amountController.dispose();
    _accountTitleController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(wholesalerProfileDataProvider);
    final minAmountAsync = ref.watch(minWithdrawalAmountProvider);
    final available = profileAsync.value?.pointsBalance ?? 0;
    final minAmount = minAmountAsync.value;

    return SgxScreen(
      title: 'Withdraw Money',
      showBack: true,
      showNotifications: false,
      children: [
        _BalanceBanner(
          amount: MoneyFormatter.format(MoneyAmount(cents: available * 100)),
          minAmount: minAmount,
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            labelText: 'How much?',
            prefixText: 'Rs. ',
            icon: Icon(Icons.payments_outlined),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          children: [
            for (final amount in const [500, 1000, 5000])
              if (amount <= available)
                ActionChip(
                  label: Text('Rs. $amount'),
                  onPressed: () =>
                      setState(() => _amountController.text = '$amount'),
                ),
            if (available > 0)
              ActionChip(
                label: Text('All (Rs. $available)'),
                onPressed: () =>
                    setState(() => _amountController.text = '$available'),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Payment method', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        for (final method in WithdrawalMethod.values)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _MethodCard(
              method: method,
              selected: _method == method,
              onTap: () => setState(() => _method = method),
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _accountTitleController,
          decoration: const InputDecoration(labelText: 'Account Title *'),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _accountNumberController,
          keyboardType: _method == WithdrawalMethod.bankTransfer
              ? TextInputType.text
              : TextInputType.phone,
          decoration: InputDecoration(
            labelText: _method.accountFieldLabel,
            hintText: _method == WithdrawalMethod.bankTransfer
                ? null
                : '03001234567',
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(_error!, style: const TextStyle(color: AppColors.error)),
        ],
        const SizedBox(height: AppSpacing.md),
        FilledButton.icon(
          onPressed: _submitting || minAmount == null
              ? null
              : () => _confirm(context, available, minAmount),
          icon: _submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.arrow_forward),
          label: const Text('Continue'),
        ),
      ],
    );
  }

  void _confirm(BuildContext context, int available, int minAmount) {
    final amount = int.tryParse(_amountController.text);
    final accountTitle = _accountTitleController.text.trim();
    final accountNumber = _accountNumberController.text.trim();

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
    if (accountTitle.isEmpty || accountNumber.isEmpty) {
      setState(() => _error = 'Account title and number are required.');
      return;
    }
    setState(() => _error = null);

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Confirm withdrawal',
              style: Theme.of(sheetContext).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              MoneyFormatter.format(MoneyAmount(cents: amount * 100)),
              style: Theme.of(
                sheetContext,
              ).textTheme.displaySmall?.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.md),
            ListTile(
              leading: const Icon(Icons.phone_android),
              title: Text(_method.label),
              subtitle: Text('$accountTitle · $accountNumber'),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: () => _submit(
                      sheetContext,
                      amount,
                      accountTitle,
                      accountNumber,
                    ),
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

  Future<void> _submit(
    BuildContext sheetContext,
    int amount,
    String accountTitle,
    String accountNumber,
  ) async {
    setState(() => _submitting = true);
    try {
      final withdrawal = await ref
          .read(withdrawalsRepositoryProvider)
          .createWithdrawal(
            amountRupees: amount,
            method: _method,
            accountTitle: accountTitle,
            accountNumber: accountNumber,
          );

      // Balance was just deducted server-side -- refetch both so Home
      // and this list reflect it immediately instead of on next app
      // launch.
      ref.invalidate(wholesalerProfileDataProvider);
      ref.invalidate(withdrawalsListProvider);

      if (!sheetContext.mounted) return;
      Navigator.pop(sheetContext);
      if (!mounted) return;
      context.go('/wholesaler/withdrawals/${withdrawal.id}');
    } catch (error) {
      if (!sheetContext.mounted) return;
      Navigator.pop(sheetContext);
      setState(() {
        _submitting = false;
        _error = 'Could not submit the request. Please try again.';
      });
    }
  }
}

class _BalanceBanner extends StatelessWidget {
  const _BalanceBanner({required this.amount, required this.minAmount});

  final String amount;
  final int? minAmount;

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
          if (minAmount != null)
            Text(
              'Minimum Rs. $minAmount',
              style: const TextStyle(color: Colors.white70),
            ),
        ],
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final WithdrawalMethod method;
  final bool selected;
  final VoidCallback onTap;

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
        onTap: onTap,
        leading: Icon(_icon(method), color: AppColors.primary),
        title: Text(method.label),
        trailing: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_off,
        ),
      ),
    );
  }

  IconData _icon(WithdrawalMethod method) => switch (method) {
    WithdrawalMethod.easyPaisa ||
    WithdrawalMethod.jazzCash => Icons.phone_android,
    WithdrawalMethod.bankTransfer => Icons.account_balance_outlined,
    WithdrawalMethod.cashCollection => Icons.store_outlined,
  };
}

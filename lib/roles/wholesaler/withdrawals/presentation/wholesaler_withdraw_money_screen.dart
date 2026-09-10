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
import '../../../../shared/withdrawals/domain/payout_account.dart';
import '../../../../shared/withdrawals/presentation/payout_provider_logo.dart';
import '../../profile/data/wholesaler_profile_providers.dart';

/// Opens the real request_withdrawal() form as a bottom sheet -- "Quiet
/// Ledger" design: a proper close button instead of relying on the
/// drag handle alone, the amount field defaults to the full available
/// balance (no separate "All" button). Every saved payout account
/// shows as a chip in a 3-per-row grid -- tap one to select it
/// entirely (filled + bordered), matching the originally approved
/// "Pay to" mockup exactly, just built from however many real
/// accounts are actually saved instead of a fixed 3. Payout method is
/// never added or changed here -- Settings > Payout Method is the one
/// place that happens; this sheet only ever picks among what's
/// already there.
///
/// The shell's own bottom nav bar/FAB (WholesalerShell) occupies this
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
  String? _selectedAccountId;
  bool _payToExpanded = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(wholesalerProfileDataProvider);
    final minAmountAsync = ref.watch(minWithdrawalAmountProvider);
    final accountsAsync = ref.watch(payoutAccountsProvider);
    final profile = profileAsync.value;
    final available = profile?.pointsBalance ?? 0;
    final minAmount = minAmountAsync.value;
    final accounts = accountsAsync.value ?? const <PayoutAccount>[];

    // Full balance by default (editable) once the real profile arrives.
    if (!_prefilled && profile != null) {
      _prefilled = true;
      _amountController.text = available > 0 ? '$available' : '';
    }

    // Default to whichever account was added first once accounts
    // arrive, but never override a selection the partner already made.
    if (_selectedAccountId == null && accounts.isNotEmpty) {
      _selectedAccountId = accounts.first.id;
    } else if (_selectedAccountId != null &&
        accounts.isNotEmpty &&
        accounts.every((a) => a.id != _selectedAccountId)) {
      // The selected account was deleted elsewhere -- fall back.
      _selectedAccountId = accounts.first.id;
    }

    final selectedAccount = accounts
        .where((a) => a.id == _selectedAccountId)
        .cast<PayoutAccount?>()
        .firstWhere((a) => a != null, orElse: () => null);

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
          if (accounts.isEmpty)
            _EmptyPayoutCard(onTap: () => _openPayoutSettings(context))
          else ...[
            Text(
              'Pay to',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.xs),
            _PayoutAccountGrid(
              accounts: accounts,
              selectedAccountId: _selectedAccountId,
              expanded: _payToExpanded,
              onSelect: (account) => setState(() {
                _selectedAccountId = account.id;
                _payToExpanded = false;
              }),
              onToggleExpanded: () =>
                  setState(() => _payToExpanded = !_payToExpanded),
            ),
          ],
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
                      selectedAccount == null
                  ? null
                  : () => _confirm(
                      context,
                      available,
                      minAmount,
                      selectedAccount,
                    ),
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
    PayoutAccount account,
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
          'via ${account.provider.label} (${account.accountNumber})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => _submit(dialogContext, amount, account.id),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(
    BuildContext dialogContext,
    int amount,
    String payoutAccountId,
  ) async {
    setState(() => _submitting = true);
    try {
      final withdrawal = await ref
          .read(withdrawalsRepositoryProvider)
          .createWithdrawal(
            amountRupees: amount,
            payoutAccountId: payoutAccountId,
          );

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

/// The approved "Pay to" grid: up to 3 chips per row, each chip's
/// width a strict fraction of the available space based on how many
/// are actually shown (2 accounts split 50/50, 3 split into thirds)
/// -- never a chip stretched to fill a whole row on its own.
///
/// At more than 3 saved accounts, the grid caps at 3 slots: the first
/// 2 real accounts, plus a "+N more" chip as the 3rd slot. Tapping it
/// does NOT open a second bottom sheet stacked on this one (Material's
/// own bottom-sheet guidance doesn't show that pattern, and it reads
/// as broken in practice) -- it expands a scrollable list in place,
/// right here inside this same sheet, with a "Show less" link to
/// collapse back. Same pattern Google Pay/Stripe's payment sheet use
/// for "choose from many saved methods".
class _PayoutAccountGrid extends StatelessWidget {
  const _PayoutAccountGrid({
    required this.accounts,
    required this.selectedAccountId,
    required this.expanded,
    required this.onSelect,
    required this.onToggleExpanded,
  });

  final List<PayoutAccount> accounts;
  final String? selectedAccountId;
  final bool expanded;
  final ValueChanged<PayoutAccount> onSelect;
  final VoidCallback onToggleExpanded;

  static const int _maxSlots = 3;

  @override
  Widget build(BuildContext context) {
    final overflowing = accounts.length > _maxSlots;

    if (overflowing && expanded) {
      return _PayoutAccountExpandedList(
        accounts: accounts,
        selectedAccountId: selectedAccountId,
        onSelect: onSelect,
        onCollapse: onToggleExpanded,
      );
    }

    // Two accounts on the same provider (e.g. two JazzCash numbers)
    // need their number shown to stay tellable apart; a lone provider
    // stays icon+label only, matching the approved chip exactly.
    final labelCounts = <String, int>{};
    for (final account in accounts) {
      labelCounts[account.provider.label] =
          (labelCounts[account.provider.label] ?? 0) + 1;
    }

    final visible = overflowing ? accounts.take(2).toList() : accounts;
    final overflowCount = overflowing ? accounts.length - visible.length : 0;
    final columns = overflowing ? _maxSlots : accounts.length.clamp(1, 3);

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = AppSpacing.sm;
        final chipWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final account in visible)
              SizedBox(
                width: chipWidth,
                child: _PayoutAccountChip(
                  account: account,
                  selected: account.id == selectedAccountId,
                  showAccountNumber:
                      (labelCounts[account.provider.label] ?? 0) > 1,
                  onTap: () => onSelect(account),
                ),
              ),
            if (overflowCount > 0)
              SizedBox(
                width: chipWidth,
                child: _MoreAccountsChip(
                  count: overflowCount,
                  onTap: onToggleExpanded,
                ),
              ),
          ],
        );
      },
    );
  }
}

/// The 3rd chip slot once there are more than 3 saved accounts --
/// opens the in-place expanded list, never a second sheet.
class _MoreAccountsChip extends StatelessWidget {
  const _MoreAccountsChip({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: 4,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.outlineOf(context),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.more_horiz, color: AppColors.mutedTextOf(context)),
            const SizedBox(height: 4),
            Text(
              '+$count more',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.mutedTextOf(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The expanded state: a scrollable one-column list of every saved
/// account, right where the chip grid was -- no navigation, no new
/// sheet, just this sheet's own content swapping in place. Picking a
/// row here selects it and collapses straight back to the compact
/// chip view, same as tapping a chip directly.
class _PayoutAccountExpandedList extends StatelessWidget {
  const _PayoutAccountExpandedList({
    required this.accounts,
    required this.selectedAccountId,
    required this.onSelect,
    required this.onCollapse,
  });

  final List<PayoutAccount> accounts;
  final String? selectedAccountId;
  final ValueChanged<PayoutAccount> onSelect;
  final VoidCallback onCollapse;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: onCollapse,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 32),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          icon: const Icon(Icons.expand_less, size: 18),
          label: const Text('Show less'),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 260),
          child: SingleChildScrollView(
            child: Column(
              children: [
                for (final account in accounts)
                  _PayoutAccountListRow(
                    account: account,
                    selected: account.id == selectedAccountId,
                    onTap: () => onSelect(account),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PayoutAccountListRow extends StatelessWidget {
  const _PayoutAccountListRow({
    required this.account,
    required this.selected,
    required this.onTap,
  });

  final PayoutAccount account;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.outlineOf(context)),
          ),
        ),
        child: Row(
          children: [
            PayoutProviderLogo(provider: account.provider, size: 26),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                '${account.provider.label} · ${account.accountNumber}',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected
                  ? AppColors.primary
                  : AppColors.mutedTextOf(context),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _PayoutAccountChip extends StatelessWidget {
  const _PayoutAccountChip({
    required this.account,
    required this.selected,
    required this.showAccountNumber,
    required this.onTap,
  });

  final PayoutAccount account;
  final bool selected;
  final bool showAccountNumber;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: 4,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.12)
              : AppColors.surfaceContainerOf(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.outlineOf(context),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PayoutProviderLogo(provider: account.provider, size: 22),
            const SizedBox(height: 6),
            Text(
              account.provider.label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.primaryDark : null,
              ),
            ),
            if (showAccountNumber)
              Text(
                account.accountNumber,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  color: AppColors.mutedTextOf(context),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// No payout account saved at all yet -- the only way in is Settings,
/// so this card is the whole "Pay to" section until one exists.
class _EmptyPayoutCard extends StatelessWidget {
  const _EmptyPayoutCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Tonal card, not an OutlinedButton -- Material 3's own guidance
    // reserves outlined buttons for a lower-emphasis, secondary
    // action. Setting up a payout method is the one thing actually
    // blocking this screen, so it gets the higher-emphasis filled
    // treatment instead.
    return InkWell(
      onTap: onTap,
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
}

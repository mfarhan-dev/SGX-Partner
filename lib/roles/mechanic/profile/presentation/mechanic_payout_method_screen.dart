import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../../../shared/widgets/sgx_screen.dart';
import '../../../../shared/withdrawals/data/withdrawals_providers.dart';
import '../../../../shared/withdrawals/domain/payout_account.dart';
import '../../../../shared/withdrawals/domain/payout_provider.dart';
import '../../../../shared/withdrawals/presentation/account_details_sheet.dart';
import '../../../../shared/withdrawals/presentation/payout_provider_logo.dart';
import '../../../../shared/withdrawals/presentation/widgets/payout_accounts_skeleton.dart';

/// A partner can save several payout accounts (a wallet AND a bank
/// account, ...) -- see payout_accounts table. Each saved account can
/// be edited or deleted on its own. There's no "default" flag to set
/// -- accounts are always shown, and used, in the order they were
/// added (oldest first), matching the same order the Withdraw Money
/// sheet's "Pay to" grid shows them in. One account per provider:
/// "Add a payout account" below only ever lists providers that aren't
/// already saved -- once EasyPaisa/JazzCash/etc. has an account, it
/// drops out of that list until deleted again.
class MechanicPayoutMethodScreen extends ConsumerWidget {
  const MechanicPayoutMethodScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(payoutAccountsProvider);
    final accounts = accountsAsync.value ?? const <PayoutAccount>[];
    final savedProviderIds = accounts.map((a) => a.provider.id).toSet();
    final addableProviders = PayoutProvider.catalog
        .where((p) => !savedProviderIds.contains(p.id))
        .toList();

    return SgxScreen(
      title: 'Payout Method',
      showBack: true,
      showNotifications: false,
      children: [
        Text(
          'This is how SGX pays you when you withdraw -- save one or more '
          'accounts here and pick which one to use each time you withdraw.',
          style: TextStyle(color: AppColors.mutedTextOf(context)),
        ),
        const SizedBox(height: AppSpacing.md),
        accountsAsync.when(
          data: (accounts) => accounts.isEmpty
              ? const SizedBox.shrink()
              : Column(
                  children: [
                    for (final account in accounts)
                      _SavedAccountRow(
                        account: account,
                        onEdit: () => _openAccountDetailsSheet(
                          context,
                          ref,
                          account.provider,
                          existing: account,
                        ),
                        onDelete: () => _confirmDelete(context, ref, account),
                      ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
          loading: () => const PayoutAccountsSkeleton(),
          error: (error, stackTrace) => Text(
            'Could not load your saved accounts.',
            style: TextStyle(color: AppColors.error),
          ),
        ),
        if (addableProviders.isNotEmpty) ...[
          Text(
            'Add a payout account',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final provider in addableProviders)
            _ProviderRow(
              provider: provider,
              onTap: () => _openAccountDetailsSheet(context, ref, provider),
            ),
        ],
      ],
    );
  }

  Future<void> _openAccountDetailsSheet(
    BuildContext context,
    WidgetRef ref,
    PayoutProvider provider, {
    PayoutAccount? existing,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => AccountDetailsSheet(
        provider: provider,
        existing: existing,
        onSaved: (_) {},
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    PayoutAccount account,
  ) async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Delete payout account?',
      message:
          'Remove ${account.provider.label} (${account.accountNumber})? '
          'This cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!confirmed) return;

    try {
      await ref
          .read(withdrawalsRepositoryProvider)
          .deletePayoutAccount(account.id);
      ref.invalidate(payoutAccountsProvider);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not delete. Please try again.')),
      );
    }
  }
}

/// One already-saved account: provider logo, title/number, plus edit
/// and delete.
class _SavedAccountRow extends StatelessWidget {
  const _SavedAccountRow({
    required this.account,
    required this.onEdit,
    required this.onDelete,
  });

  final PayoutAccount account;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerOf(context),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          PayoutProviderLogo(provider: account.provider, size: 30),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.provider.label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  '${account.accountTitle} · ${account.accountNumber}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.mutedTextOf(context),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Edit',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 20),
          ),
          IconButton(
            tooltip: 'Delete',
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline, size: 20, color: AppColors.error),
          ),
        ],
      ),
    );
  }
}

/// Row for the "add a payout account" catalog -- only providers not
/// already saved (see [MechanicPayoutMethodScreen.build]'s
/// addableProviders filter).
class _ProviderRow extends StatelessWidget {
  const _ProviderRow({required this.provider, required this.onTap});

  final PayoutProvider provider;
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
            PayoutProviderLogo(provider: provider, size: 28),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                provider.label,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            Icon(
              Icons.add_circle_outline,
              color: AppColors.mutedTextOf(context),
            ),
          ],
        ),
      ),
    );
  }
}

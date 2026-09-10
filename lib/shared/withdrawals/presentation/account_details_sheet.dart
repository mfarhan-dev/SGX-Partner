import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../data/withdrawals_providers.dart';
import '../domain/payout_account.dart';
import '../domain/payout_provider.dart';
import 'payout_provider_logo.dart';

/// Add ([existing] null) or edit ([existing] set) one account's
/// details, as a bottom sheet. Shared by the Payout Method screen and
/// the Withdraw Money sheet's "add another account" flow. Validates
/// the account number against the shape the provider actually
/// expects -- a phone number for a wallet, an account number/IBAN for
/// a bank -- so a withdrawal can never be requested against something
/// obviously wrong.
class AccountDetailsSheet extends ConsumerStatefulWidget {
  const AccountDetailsSheet({
    super.key,
    required this.provider,
    required this.onSaved,
    this.existing,
  });

  final PayoutProvider provider;
  final PayoutAccount? existing;
  final void Function(PayoutAccount account) onSaved;

  @override
  ConsumerState<AccountDetailsSheet> createState() =>
      _AccountDetailsSheetState();
}

class _AccountDetailsSheetState extends ConsumerState<AccountDetailsSheet> {
  final _accountTitleController = TextEditingController();
  final _accountNumberController = TextEditingController();
  bool _saving = false;
  String? _error;

  static final _mobileNumberPattern = RegExp(r'^03\d{9}$');
  static final _bankAccountPattern = RegExp(r'^[A-Za-z0-9]{5,34}$');

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _accountTitleController.text = existing.accountTitle;
      _accountNumberController.text = existing.accountNumber;
    }
  }

  @override
  void dispose() {
    _accountTitleController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    final isEditing = widget.existing != null;
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
            children: [
              PayoutProviderLogo(provider: provider, size: 30),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  provider.label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
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
            controller: _accountTitleController,
            decoration: const InputDecoration(labelText: 'Account Title *'),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _accountNumberController,
            keyboardType: provider.kind == PayoutProviderKind.bank
                ? TextInputType.text
                : TextInputType.phone,
            decoration: InputDecoration(
              labelText: provider.accountFieldLabel,
              hintText: provider.kind == PayoutProviderKind.bank
                  ? null
                  : '03001234567',
            ),
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
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(
                isEditing ? 'Save Payout Method' : 'Add Payout Method',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final accountTitle = _accountTitleController.text.trim();
    final accountNumber = _accountNumberController.text.trim();
    final provider = widget.provider;

    if (accountTitle.isEmpty || accountNumber.isEmpty) {
      setState(() => _error = 'Account title and number are required.');
      return;
    }
    if (accountTitle.length < 2) {
      setState(() => _error = 'Enter a valid account title.');
      return;
    }
    if (provider.kind == PayoutProviderKind.wallet) {
      if (!_mobileNumberPattern.hasMatch(accountNumber)) {
        setState(
          () => _error = 'Enter a valid mobile number (e.g. 03001234567).',
        );
        return;
      }
    } else {
      final normalized = accountNumber.replaceAll(' ', '');
      if (!_bankAccountPattern.hasMatch(normalized)) {
        setState(() => _error = 'Enter a valid account number or IBAN.');
        return;
      }
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final repository = ref.read(withdrawalsRepositoryProvider);
      final existing = widget.existing;
      final PayoutAccount saved;
      if (existing != null) {
        saved = await repository.updatePayoutAccount(
          accountId: existing.id,
          accountTitle: accountTitle,
          accountNumber: accountNumber,
        );
      } else {
        saved = await repository.addPayoutAccount(
          provider: provider,
          accountTitle: accountTitle,
          accountNumber: accountNumber,
        );
      }
      ref.invalidate(payoutAccountsProvider);
      widget.onSaved(saved);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Payout method saved.')));
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'Could not save. Please try again.';
      });
    }
  }
}

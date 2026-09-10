import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/sgx_screen.dart';
import '../../../../shared/withdrawals/data/withdrawals_providers.dart';
import '../../../../shared/withdrawals/domain/withdrawal_method.dart';
import '../data/mechanic_profile_providers.dart';

/// Set once here in Settings, not re-entered on every withdrawal --
/// request_withdrawal() snapshots whatever is saved here onto each
/// new withdrawal automatically. Same pattern as DoorDash Dasher's
/// "Payout Methods" screen: one active method, switchable. No cash
/// option -- every method needs real account details so staff can
/// actually reconcile it in the admin panel.
class MechanicPayoutMethodScreen extends ConsumerStatefulWidget {
  const MechanicPayoutMethodScreen({super.key});

  @override
  ConsumerState<MechanicPayoutMethodScreen> createState() =>
      _MechanicPayoutMethodScreenState();
}

class _MechanicPayoutMethodScreenState
    extends ConsumerState<MechanicPayoutMethodScreen> {
  WithdrawalMethod? _selected;
  final _accountTitleController = TextEditingController();
  final _accountNumberController = TextEditingController();
  bool _saving = false;
  String? _error;
  bool _prefilled = false;

  @override
  void dispose() {
    _accountTitleController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(mechanicProfileDataProvider);
    final profile = profileAsync.value;

    // Prefill once the real saved method arrives -- not in initState,
    // since the profile is still loading at that point.
    if (!_prefilled && profile != null) {
      _prefilled = true;
      _selected = profile.payoutMethod;
      _accountTitleController.text = profile.payoutAccountTitle ?? '';
      _accountNumberController.text = profile.payoutAccountNumber ?? '';
    }

    final selected = _selected ?? WithdrawalMethod.easyPaisa;

    return SgxScreen(
      title: 'Payout Method',
      showBack: true,
      showNotifications: false,
      children: [
        Text(
          'This is how SGX pays you when you withdraw -- set it once here '
          'and every withdrawal request will use it automatically.',
          style: TextStyle(color: AppColors.mutedTextOf(context)),
        ),
        const SizedBox(height: AppSpacing.md),
        for (final method in WithdrawalMethod.values)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _MethodCard(
              method: method,
              selected: selected == method,
              onTap: () => setState(() => _selected = method),
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
          keyboardType: selected == WithdrawalMethod.bankTransfer
              ? TextInputType.text
              : TextInputType.phone,
          decoration: InputDecoration(
            labelText: selected.accountFieldLabel,
            hintText: selected == WithdrawalMethod.bankTransfer
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
          onPressed: _saving ? null : () => _save(selected),
          icon: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check),
          label: const Text('Save Payout Method'),
        ),
      ],
    );
  }

  Future<void> _save(WithdrawalMethod method) async {
    final accountTitle = _accountTitleController.text.trim();
    final accountNumber = _accountNumberController.text.trim();

    if (accountTitle.isEmpty || accountNumber.isEmpty) {
      setState(() => _error = 'Account title and number are required.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await ref
          .read(withdrawalsRepositoryProvider)
          .setPayoutMethod(
            method: method,
            accountTitle: accountTitle,
            accountNumber: accountNumber,
          );
      ref.invalidate(mechanicProfileDataProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Payout method saved.')));
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'Could not save. Please try again.';
      });
    }
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
          color: selected ? AppColors.primary : AppColors.outlineOf(context),
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
  };
}

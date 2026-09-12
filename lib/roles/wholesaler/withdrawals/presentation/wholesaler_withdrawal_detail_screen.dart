import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../shared/widgets/sgx_screen.dart';
import '../../../../shared/widgets/whatsapp_fab.dart';
import '../../../../shared/withdrawals/data/withdrawals_providers.dart';
import '../../../../shared/withdrawals/domain/withdrawal.dart';
import '../../../../shared/withdrawals/domain/withdrawal_activity_event.dart';
import '../../../../shared/withdrawals/domain/withdrawal_status.dart';
import '../../../../shared/withdrawals/presentation/widgets/withdrawal_status_chip.dart';
import '../../../../shared/withdrawals/presentation/widgets/withdrawal_timeline_list.dart';
import '../../profile/data/wholesaler_profile_providers.dart';

class WholesalerWithdrawalDetailScreen extends ConsumerWidget {
  const WholesalerWithdrawalDetailScreen({
    super.key,
    required this.withdrawalId,
  });

  final String withdrawalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final withdrawalAsync = ref.watch(withdrawalDetailProvider(withdrawalId));
    // Same admin WhatsApp number Settings already fetches -- reused
    // here for the floating contact button instead of the old
    // do-nothing stub button.
    final profileAsync = ref.watch(wholesalerProfileDataProvider);
    final whatsappNumber = profileAsync.value?.adminWhatsappNumber;

    return SgxScreen(
      title: 'Withdrawal Detail',
      showBack: true,
      showNotifications: false,
      floatingActionButton: WhatsAppFab(
        onPressed: () => _contactSgx(context, whatsappNumber),
      ),
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

/// Same wa.me deep link logic as the Settings screen's own "Contact
/// SGX" row.
Future<void> _contactSgx(BuildContext context, String? whatsappNumber) async {
  if (whatsappNumber == null || whatsappNumber.isEmpty) return;

  final digits = whatsappNumber.replaceAll(RegExp(r'[^0-9]'), '');
  // wa.me needs a full international number with no leading 0 -- treat
  // an 11-digit number starting with 0 as a local PK number missing
  // its 92 country code, same convention used elsewhere in this app.
  final international = digits.startsWith('0')
      ? '92${digits.substring(1)}'
      : digits;

  final uri = Uri.parse('https://wa.me/$international');
  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

  if (!launched && context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Could not open WhatsApp.')));
  }
}

/// Header order is amount &rarr; status &rarr; method/reference -- the
/// status chip sits right under the number it's describing instead of
/// floating above it before you've even seen what it's the status OF.
/// Timeline events (real source once the audit_logs RPC lands, see
/// [buildWithdrawalActivityEvents]'s own doc comment) render in full via
/// [WithdrawalTimelineList] -- this screen is the one place the
/// complete history shows; Home's own card stays a compact summary.
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
    final awaitingConfirmation =
        withdrawal.status == WithdrawalStatus.paymentSent;
    // Only fetched when a proof actually exists on this withdrawal --
    // older withdrawals or ones sent without a screenshot never hit
    // storage at all.
    final proofPath = withdrawal.proofStoragePath;
    final proofUrlAsync = proofPath == null
        ? null
        : ref.watch(withdrawalProofUrlProvider(proofPath));
    final events = buildWithdrawalActivityEvents(
      withdrawal,
      proofImageUrl: proofUrlAsync?.value,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              Text(
                MoneyFormatter.format(withdrawal.amount),
                // Sora, same display face every approved mockup for
                // this app has used -- heavier weight and tighter
                // letter-spacing than the plain Material default so
                // the number this whole screen is about actually
                // reads as the headline, matching WalletHeroCard's
                // own big-amount treatment on Home.
                style: GoogleFonts.sora(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                  color: AppColors.textOf(context),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              WithdrawalStatusChip(withdrawal: withdrawal),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${withdrawal.method.label} · ${withdrawal.withdrawalNo}',
                style: TextStyle(color: AppColors.mutedTextOf(context)),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        WithdrawalTimelineList(
          events: events,
          submitting: _submitting,
          onConfirmReceived: awaitingConfirmation ? _confirmReceived : null,
          onNotReceived: awaitingConfirmation ? _disputeReceived : null,
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
      ref.invalidate(wholesalerProfileDataProvider);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not submit. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
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

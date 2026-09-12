import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/withdrawal.dart';
import '../../domain/withdrawal_status.dart';

enum _ChipTone { pending, action, alert, success }

/// The Withdrawal Detail screen's status chip -- semantic color, not
/// one color for every state: amber = waiting on SGX, red outline =
/// waiting on YOU, red filled = a real problem (a live dispute), green
/// filled = done. Same red hue throughout (on-brand), but outline vs.
/// filled carries the actual meaning, so "Payment Sent" (your turn)
/// and "Needs Review" (something's wrong) never read as the same
/// urgency at a glance. Text only -- no leading icon; the color alone
/// already carries the state, and the icon crowded the label.
class WithdrawalStatusChip extends StatelessWidget {
  const WithdrawalStatusChip({super.key, required this.withdrawal});

  final Withdrawal withdrawal;

  @override
  Widget build(BuildContext context) {
    final (label, tone) = _resolve(withdrawal);
    final Color background;
    final Color foreground;
    BoxBorder? border;

    switch (tone) {
      case _ChipTone.pending:
        background = AppColors.warningContainer;
        foreground = AppColors.warning;
      case _ChipTone.action:
        background = Colors.transparent;
        foreground = AppColors.primary;
        border = Border.all(color: AppColors.primary, width: 1.5);
      case _ChipTone.alert:
        background = AppColors.error;
        foreground = Colors.white;
      case _ChipTone.success:
        background = AppColors.success;
        foreground = Colors.white;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        border: border,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w700,
          fontSize: 12.5,
        ),
      ),
    );
  }

  (String, _ChipTone) _resolve(Withdrawal withdrawal) {
    final wentThroughDispute = withdrawal.disputeReason != null;
    return switch (withdrawal.status) {
      WithdrawalStatus.pending => ('Pending', _ChipTone.pending),
      WithdrawalStatus.paymentSent => ('Payment Sent', _ChipTone.action),
      WithdrawalStatus.disputed => ('Needs Review', _ChipTone.alert),
      WithdrawalStatus.confirmed => (
        wentThroughDispute ? 'Resolved' : 'Confirmed',
        _ChipTone.success,
      ),
      WithdrawalStatus.autoConfirmed => ('Auto-confirmed', _ChipTone.success),
      WithdrawalStatus.refunded => ('Refunded', _ChipTone.success),
    };
  }
}

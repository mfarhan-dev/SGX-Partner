import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../domain/withdrawal.dart';
import '../../domain/withdrawal_activity_event.dart';
import '../../domain/withdrawal_status.dart';

/// Home's "current withdrawal" banner. Only ever shown for a withdrawal
/// that is NOT terminal (pending/paymentSent/disputed) -- the caller is
/// responsible for picking that row and not rendering this at all when
/// there isn't one, so a partner who has never requested a withdrawal
/// sees nothing here instead of stale/fake status.
///
/// A fixed, non-expandable summary: the last 3 real milestones as a
/// dot strip, plus a one-line note. It always reflects whatever
/// actually happened -- once a dispute resolves, the strip moves on
/// to show the resolution instead of staying stuck on "Reviewing" --
/// but there's no "view full activity" control here. The complete
/// history (every event, always expanded) lives on the Withdrawal
/// Detail screen this card opens; Home only ever needs "what's the
/// status right now."
///
/// Events currently come from [buildWithdrawalActivityEvents], a
/// client-side stand-in -- see that function's own doc comment for
/// why, and what replaces it once the real `audit_logs` feed is wired
/// up as a partner-scoped RPC.
class WithdrawalActivityCard extends StatelessWidget {
  const WithdrawalActivityCard({
    super.key,
    required this.withdrawal,
    required this.routePrefix,
  });

  final Withdrawal withdrawal;
  final String routePrefix;

  @override
  Widget build(BuildContext context) {
    final status = withdrawal.status;
    final paymentSent = status == WithdrawalStatus.paymentSent;
    final events = buildWithdrawalActivityEvents(withdrawal);

    final title = switch (status) {
      WithdrawalStatus.paymentSent => 'Payment sent by SGX',
      WithdrawalStatus.disputed => 'Withdrawal needs review',
      WithdrawalStatus.confirmed ||
      WithdrawalStatus.autoConfirmed => 'Withdrawal confirmed',
      WithdrawalStatus.refunded => 'Withdrawal refunded',
      WithdrawalStatus.pending => 'Withdrawal requested',
    };
    final pillLabel = paymentSent ? 'Confirm' : status.label;

    return Card(
      margin: EdgeInsets.zero,
      color: _cardColor(status),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('$routePrefix/${withdrawal.id}'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            _StatusPill(
                              label: pillLabel,
                              color: _accentColor(status),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${MoneyFormatter.format(withdrawal.amount)} · ${withdrawal.method.label} · ${_formatDate(withdrawal.requestedAt)}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.mutedTextOf(context)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _DotStrip(events: events, accent: _accentColor(status)),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _summaryNote(status, withdrawal.disputeReason),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.mutedTextOf(context),
                ),
              ),
              if (paymentSent) ...[
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () =>
                        context.push('$routePrefix/${withdrawal.id}'),
                    child: const Text('Confirm received'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _summaryNote(WithdrawalStatus status, String? disputeReason) {
    return switch (status) {
      WithdrawalStatus.paymentSent =>
        'Confirm only after the amount is received.',
      WithdrawalStatus.disputed =>
        disputeReason ?? 'SGX is reviewing this payment problem.',
      WithdrawalStatus.confirmed ||
      WithdrawalStatus.autoConfirmed => 'Payment received and closed.',
      WithdrawalStatus.refunded => 'Refunded to your balance.',
      WithdrawalStatus.pending =>
        'SGX is reviewing the request. No action is required right now.',
    };
  }

  Color _cardColor(WithdrawalStatus status) {
    return switch (status) {
      WithdrawalStatus.disputed => AppColors.errorContainer,
      WithdrawalStatus.confirmed ||
      WithdrawalStatus.autoConfirmed ||
      WithdrawalStatus.refunded => AppColors.successContainer,
      _ => AppColors.warningContainer,
    };
  }

  Color _accentColor(WithdrawalStatus status) {
    return switch (status) {
      WithdrawalStatus.confirmed ||
      WithdrawalStatus.autoConfirmed ||
      WithdrawalStatus.refunded => AppColors.success,
      WithdrawalStatus.disputed => AppColors.error,
      WithdrawalStatus.paymentSent => AppColors.primary,
      WithdrawalStatus.pending => AppColors.warning,
    };
  }
}

/// The last 3 real events, never a fixed "Requested/Sent/Confirmed"
/// label set -- so it stays accurate as the withdrawal actually
/// progresses (a dispute resolving moves the strip on to show the
/// resolution) without ever offering a way to drill into the rest.
class _DotStrip extends StatelessWidget {
  const _DotStrip({required this.events, required this.accent});

  final List<WithdrawalActivityEvent> events;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final last3 = events.length > 3
        ? events.sublist(events.length - 3)
        : events;

    return Row(
      children: [
        for (var i = 0; i < last3.length; i++) ...[
          Expanded(
            child: Column(
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _dotColor(last3[i].kind, accent),
                    border: last3[i].kind == WithdrawalActivityKind.upcoming
                        ? Border.all(color: AppColors.outlineOf(context))
                        : null,
                    boxShadow: _isCurrent(last3[i])
                        ? [
                            BoxShadow(
                              color: AppColors.error.withValues(alpha: 0.25),
                              blurRadius: 0,
                              spreadRadius: 3,
                            ),
                          ]
                        : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  last3[i].shortLabel,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: _isCurrent(last3[i]) ? 11 : 9.5,
                    fontWeight: _isCurrent(last3[i])
                        ? FontWeight.w800
                        : FontWeight.w700,
                    // The step that actually needs a look (a live
                    // dispute, an awaiting-you moment) gets the accent
                    // color and a bigger size -- a completed step
                    // fades to muted grey since there's nothing more
                    // to say about it, and an upcoming one fades
                    // further since it hasn't happened yet.
                    color: _isCurrent(last3[i])
                        ? AppColors.error
                        : last3[i].kind == WithdrawalActivityKind.upcoming
                        ? AppColors.mutedTextOf(context).withValues(alpha: 0.5)
                        : AppColors.mutedTextOf(context),
                  ),
                ),
              ],
            ),
          ),
          if (i < last3.length - 1)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.only(bottom: 14),
                color: last3[i].kind == WithdrawalActivityKind.upcoming
                    ? AppColors.outlineOf(context)
                    : accent.withValues(alpha: 0.4),
              ),
            ),
        ],
      ],
    );
  }

  Color _dotColor(WithdrawalActivityKind kind, Color accent) {
    return switch (kind) {
      WithdrawalActivityKind.done => AppColors.success,
      WithdrawalActivityKind.upcoming => Colors.transparent,
      WithdrawalActivityKind.action ||
      WithdrawalActivityKind.warn => AppColors.error,
      WithdrawalActivityKind.success => AppColors.success,
    };
  }

  /// The one step that actually needs a look right now -- a live
  /// dispute, or "awaiting your confirmation" while payment's already
  /// sent. Done/success steps are settled; a true upcoming placeholder
  /// hasn't happened yet -- neither needs to shout.
  bool _isCurrent(WithdrawalActivityEvent event) =>
      event.kind == WithdrawalActivityKind.action ||
      event.kind == WithdrawalActivityKind.warn;
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

String _formatDate(DateTime dateTime) {
  final local = dateTime.toLocal();
  final now = DateTime.now();
  final isToday =
      local.year == now.year &&
      local.month == now.month &&
      local.day == now.day;
  return isToday
      ? 'Today · ${DateFormat('h:mm a').format(local)}'
      : DateFormat('d MMM y, h:mm a').format(local);
}

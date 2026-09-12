import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../domain/withdrawal_activity_event.dart';

/// The Withdrawal Detail screen's full activity timeline -- every
/// event, oldest first, always expanded (this is the one screen with
/// room for the complete history; Home's own card stays a compact
/// summary). Each row keeps an always-visible description, StubHub's
/// own order-timeline pattern: https://mobbin.com/screens/b3c71fe5-884d-4f57-85a2-8b39192d46d8
///
/// The Confirm/Not Received buttons live inline on whichever step is
/// actually "Awaiting your confirmation" -- not a separate card
/// floating above the timeline -- so the action sits exactly where
/// the thing it acts on is.
class WithdrawalTimelineList extends StatelessWidget {
  const WithdrawalTimelineList({
    super.key,
    required this.events,
    this.onConfirmReceived,
    this.onNotReceived,
    this.submitting = false,
  });

  final List<WithdrawalActivityEvent> events;

  /// Both null when there's nothing to confirm right now (any status
  /// other than payment_sent) -- the awaiting-confirmation step then
  /// renders as plain text with no buttons.
  final VoidCallback? onConfirmReceived;
  final VoidCallback? onNotReceived;
  final bool submitting;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < events.length; i++)
          _TimelineRow(
            event: events[i],
            isLast: i == events.length - 1,
            onConfirmReceived: onConfirmReceived,
            onNotReceived: onNotReceived,
            submitting: submitting,
          ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.event,
    required this.isLast,
    required this.onConfirmReceived,
    required this.onNotReceived,
    required this.submitting,
  });

  final WithdrawalActivityEvent event;
  final bool isLast;
  final VoidCallback? onConfirmReceived;
  final VoidCallback? onNotReceived;
  final bool submitting;

  bool get _showsConfirmButtons =>
      onConfirmReceived != null && event.title == 'Awaiting your confirmation';

  @override
  Widget build(BuildContext context) {
    final color = switch (event.kind) {
      WithdrawalActivityKind.done ||
      WithdrawalActivityKind.success => AppColors.success,
      WithdrawalActivityKind.upcoming => AppColors.mutedTextOf(context),
      WithdrawalActivityKind.action ||
      WithdrawalActivityKind.warn => AppColors.error,
    };
    final icon = switch (event.kind) {
      WithdrawalActivityKind.done ||
      WithdrawalActivityKind.success => Icons.check,
      WithdrawalActivityKind.upcoming => Icons.circle_outlined,
      WithdrawalActivityKind.action ||
      WithdrawalActivityKind.warn => Icons.priority_high,
    };
    final isUpcoming = event.kind == WithdrawalActivityKind.upcoming;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
      // The connector line below the dot is an Expanded inside a
      // Column, which needs a bounded height to expand into. This Row
      // sits in a plain Column inside a ListView, so without
      // IntrinsicHeight forcing a bounded height (taken from the text
      // column's own intrinsic height), that Expanded has nothing to
      // expand into and the layout throws ("RenderBox was not laid
      // out" / hasSize false).
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isUpcoming ? Colors.transparent : color,
                    border: Border.all(color: color, width: 1.5),
                  ),
                  child: Icon(
                    icon,
                    size: 14,
                    color: isUpcoming ? color : Colors.white,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: AppColors.outlineOf(context),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  top: 3,
                  bottom: isLast ? 0 : AppSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // The title (e.g. "Payment sent by SGX", "Marked
                    // as not received") already says who did it --
                    // a separate "You"/"SGX" chip alongside every
                    // single row was redundant clutter.
                    Text(
                      event.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (event.note != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        event.note!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedTextOf(context),
                        ),
                      ),
                    ] else if (isUpcoming) ...[
                      const SizedBox(height: 3),
                      Text(
                        'Not yet reached',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedTextOf(context),
                        ),
                      ),
                    ],
                    if (event.timestamp != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        _formatTimestamp(event.timestamp!),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.mutedTextOf(context),
                        ),
                      ),
                    ],
                    if (event.imageUrl != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      _ProofThumbnail(imageUrl: event.imageUrl!),
                    ],
                    if (event.isFinal && event.actorLabel == 'SGX') ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Final — no action needed from you',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ],
                    if (_showsConfirmButtons) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: submitting ? null : onNotReceived,
                              child: const Text('Not Received'),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: FilledButton(
                              onPressed: submitting ? null : onConfirmReceived,
                              child: submitting
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime dateTime) =>
      DateFormat('d MMM, h:mm a').format(dateTime.toLocal());
}

/// SGX's payment-proof screenshot, embedded right on the "Payment
/// sent by SGX" step -- deliberately small and fixed-size (not a full
/// receipt-height image) since it's here to confirm "yes, a real
/// screenshot exists," not to be read at this size. Tap opens a
/// full-screen pinch-to-zoom view for actually reading amounts/account
/// numbers off it.
class _ProofThumbnail extends StatelessWidget {
  const _ProofThumbnail({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openProofViewer(context, imageUrl),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 100,
          height: 140,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.outlineOf(context)),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.mutedTextOf(context),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.broken_image_outlined,
                  color: AppColors.mutedTextOf(context),
                ),
              ),
              Positioned(
                right: 4,
                bottom: 4,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.zoom_in,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _openProofViewer(BuildContext context, String imageUrl) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.92),
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppSpacing.md),
      child: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              maxScale: 4,
              child: Image.network(
                imageUrl,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image_outlined,
                  color: Colors.white54,
                  size: 48,
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              icon: const Icon(Icons.close, color: Colors.white),
              style: IconButton.styleFrom(backgroundColor: Colors.black38),
            ),
          ),
        ],
      ),
    ),
  );
}

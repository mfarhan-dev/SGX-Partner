import 'withdrawal.dart';
import 'withdrawal_status.dart';

/// Visual/semantic weight of one activity event -- drives the dot/log
/// icon and color. Not the same thing as [WithdrawalStatus]: several
/// events can share a status (e.g. "Requested" and "Payment sent" are
/// both simply `done`) and a dispute introduces states that aren't a
/// [WithdrawalStatus] at all.
enum WithdrawalActivityKind { done, upcoming, action, warn, success }

/// One entry in a withdrawal's activity history. Mirrors exactly what
/// the real `audit_logs` feed already contains on the backend
/// (actor name/role, action, a summary, an optional note) -- see
/// [buildWithdrawalActivityEvents]'s own doc comment for why this is
/// still client-derived for now instead of reading that table.
class WithdrawalActivityEvent {
  const WithdrawalActivityEvent({
    required this.title,
    required this.shortLabel,
    required this.kind,
    this.note,
    this.timestamp,
    this.actorLabel,
    this.isFinal = false,
    this.imageUrl,
  });

  /// Full sentence shown in the expanded log, e.g. "Marked as not
  /// received".
  final String title;

  /// Short word/phrase shown in the collapsed dot strip, e.g. "Not
  /// received". Kept separate from [title] because the dot strip has
  /// far less room than a full log row.
  final String shortLabel;

  final WithdrawalActivityKind kind;

  /// Extra detail for the expanded log only -- a dispute reason, a
  /// staff resolution note, etc. Never shown in the dot strip.
  final String? note;

  final DateTime? timestamp;

  /// "You" or "SGX" -- who actually did this. Null for a not-yet-
  /// reached placeholder step, since nobody has done anything yet.
  final String? actorLabel;

  /// True for a step that closes the story with nothing left for the
  /// partner to do -- shown with a small reassurance line in the log
  /// when [actorLabel] is "SGX", since that's the case that reads as
  /// ambiguous otherwise ("did SGX confirm, or do I still need to?").
  final bool isFinal;

  /// Signed URL for SGX's payment-proof screenshot -- only ever set on
  /// the "Payment sent by SGX" event, and only once
  /// [withdrawalProofUrlProvider] has resolved one. Null everywhere
  /// else, and null there too when no proof was uploaded for this
  /// withdrawal or the signed URL hasn't loaded yet.
  final String? imageUrl;
}

/// Builds this withdrawal's activity history from the fields already
/// on the [Withdrawal] model.
///
/// This is a stand-in for the real timeline: the backend already logs
/// every one of these events into `audit_logs` (confirm/dispute RPCs
/// both insert a row there), but that table is currently admin-only
/// readable -- a partner-scoped RPC to expose it is the next step.
/// Until that lands, this derives the same shape from data the app
/// can already see, so the widget that renders it doesn't need to
/// change at all once the real feed is wired in -- only this function
/// gets replaced by an API call.
///
/// [proofImageUrl] is a signed URL for SGX's payment-proof screenshot,
/// resolved separately (see withdrawalProofUrlProvider -- kept out of
/// this function since building the event list itself is synchronous).
/// Used as a fallback for the "Payment sent by SGX" event only when
/// [paymentEvents] is empty.
///
/// [paymentEvents] is this withdrawal's full "marked paid" history from
/// `audit_logs` (see withdrawalPaymentEventsProvider), oldest first,
/// with each entry's own proof already resolved to a signed URL. The
/// `withdrawals` row's own paymentSentAt/proofStoragePath only ever
/// holds the *latest* payment -- a re-pay after a dispute overwrites
/// both -- so once there's more than one payment event, this is the
/// only way to show the first payment's own screenshot on its own
/// step instead of it being silently replaced by the re-pay's.
List<WithdrawalActivityEvent> buildWithdrawalActivityEvents(
  Withdrawal withdrawal, {
  String? proofImageUrl,
  List<({DateTime paidAt, String? proofUrl})> paymentEvents = const [],
}) {
  final status = withdrawal.status;
  final wentThroughDispute = withdrawal.disputeReason != null;
  final events = <WithdrawalActivityEvent>[
    WithdrawalActivityEvent(
      title: 'Withdrawal requested',
      shortLabel: 'Requested',
      kind: WithdrawalActivityKind.done,
      timestamp: withdrawal.requestedAt,
      actorLabel: 'You',
    ),
  ];

  if (paymentEvents.isNotEmpty) {
    events.add(
      WithdrawalActivityEvent(
        title: 'Payment sent by SGX',
        shortLabel: 'Payment sent',
        kind: WithdrawalActivityKind.done,
        timestamp: paymentEvents.first.paidAt,
        actorLabel: 'SGX',
        imageUrl: paymentEvents.first.proofUrl,
      ),
    );
  } else if (withdrawal.paymentSentAt != null) {
    events.add(
      WithdrawalActivityEvent(
        title: 'Payment sent by SGX',
        shortLabel: 'Payment sent',
        kind: WithdrawalActivityKind.done,
        timestamp: withdrawal.paymentSentAt,
        actorLabel: 'SGX',
        imageUrl: proofImageUrl,
      ),
    );
  } else {
    events.add(
      const WithdrawalActivityEvent(
        title: 'Payment sent by SGX',
        shortLabel: 'Payment sent',
        kind: WithdrawalActivityKind.upcoming,
      ),
    );
  }

  if (wentThroughDispute) {
    // A completed action in its own right (you already reported it) --
    // `done`, not `action`. The live "needs a look" emphasis belongs
    // to whatever comes next: SGX still reviewing it, or nothing
    // further once resolved.
    events.add(
      WithdrawalActivityEvent(
        title: 'Marked as not received by you',
        shortLabel: 'Not received',
        kind: WithdrawalActivityKind.done,
        note: withdrawal.disputeReason,
        timestamp: withdrawal.disputedAt,
        actorLabel: 'You',
      ),
    );

    // Every payment after the first is SGX re-sending following that
    // dispute -- each gets its own step with its own screenshot,
    // chronologically after the dispute that prompted it.
    for (final repay in paymentEvents.skip(1)) {
      events.add(
        WithdrawalActivityEvent(
          title: 'Payment sent again by SGX',
          shortLabel: 'Repaid',
          kind: WithdrawalActivityKind.done,
          timestamp: repay.paidAt,
          actorLabel: 'SGX',
          imageUrl: repay.proofUrl,
        ),
      );
    }
  }

  switch (status) {
    case WithdrawalStatus.pending:
      // Payment hasn't even been sent yet -- this slot genuinely
      // hasn't happened, so it stays a plain upcoming placeholder.
      events.add(
        const WithdrawalActivityEvent(
          title: 'Awaiting your confirmation',
          shortLabel: 'Awaiting you',
          kind: WithdrawalActivityKind.upcoming,
        ),
      );
    case WithdrawalStatus.paymentSent:
      // This IS the live, actionable moment (the card's CTA is
      // showing right now) -- `action`, not `upcoming`, so it gets
      // the same "look here" emphasis as a dispute does, instead of
      // fading out like a step that truly hasn't happened yet.
      events.add(
        const WithdrawalActivityEvent(
          title: 'Awaiting your confirmation',
          shortLabel: 'Awaiting you',
          kind: WithdrawalActivityKind.action,
        ),
      );
    case WithdrawalStatus.disputed:
      // Still under review -- this, not the dispute entry above, is
      // the live "needs a look" step right now.
      events.add(
        const WithdrawalActivityEvent(
          title: 'SGX is reviewing',
          shortLabel: 'Reviewing',
          kind: WithdrawalActivityKind.warn,
          note: 'Support is checking with the payment provider.',
          actorLabel: 'SGX',
        ),
      );
    case WithdrawalStatus.confirmed:
      events.add(
        wentThroughDispute
            ? WithdrawalActivityEvent(
                title: 'Resolved by SGX',
                shortLabel: 'Resolved',
                kind: WithdrawalActivityKind.success,
                note: 'Payment confirmed as received on our end.',
                timestamp: withdrawal.confirmedAt,
                actorLabel: 'SGX',
                isFinal: true,
              )
            : WithdrawalActivityEvent(
                title: 'You confirmed receipt',
                shortLabel: 'Confirmed',
                kind: WithdrawalActivityKind.success,
                timestamp: withdrawal.confirmedAt,
                actorLabel: 'You',
                isFinal: true,
              ),
      );
    case WithdrawalStatus.autoConfirmed:
      events.add(
        WithdrawalActivityEvent(
          title: 'Auto-confirmed',
          shortLabel: 'Auto-confirmed',
          kind: WithdrawalActivityKind.success,
          note: 'No response after 3 days -- automatically marked as received.',
          timestamp: withdrawal.confirmedAt,
          actorLabel: 'SGX',
          isFinal: true,
        ),
      );
    case WithdrawalStatus.refunded:
      events.add(
        const WithdrawalActivityEvent(
          title: 'Refunded to your balance',
          shortLabel: 'Refunded',
          kind: WithdrawalActivityKind.success,
          note: 'The amount was credited back to your available balance.',
          actorLabel: 'SGX',
          isFinal: true,
        ),
      );
  }

  return events;
}

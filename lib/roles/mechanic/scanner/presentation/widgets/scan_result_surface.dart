import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../domain/scan_result.dart';

/// The scanner's own result overlay. By the time this shows, the
/// camera has already stopped (see qr_scanner_screen.dart) -- there is
/// nothing dark behind it any more, so unlike the idle scanning view
/// and its "Verifying..." step, this one is a normal themed screen
/// (`AppColors.xOf(context)`, same rule as everywhere else in the
/// app), not fixed dark. Solid, not translucent: a lower-alpha scrim
/// let the idle screen's own aiming-frame decoration show faintly
/// through, landing right behind the button and reading as a broken
/// dialog -- still true regardless of which theme this resolves to.
/// Told apart by icon/tone alone (same "color carries the state" rule
/// as WithdrawalStatusChip), with the credited amount in the same Sora
/// display face the Withdrawal Detail screen already uses for money.
///
/// Sized like a real full-screen confirmation state (Google Pay/PayPal
/// success screens), not a compact card -- this is the only thing on
/// screen, on a full-height phone display, so it needs to read from
/// arm's length, not card-sized.
///
/// The check/exclamation mark is a plain text glyph (✓ / !), not a
/// Material icon -- `Icons.check_circle`/`Icons.error_outline` each
/// draw their own circle baked into the glyph, which doubled up into a
/// ring-inside-a-ring against the CircleAvatar's own circle.
///
/// Three tones, not two: success (green), an honest mistake -- someone
/// already claimed this sticker, most often the mechanic's own earlier
/// scan or a colleague's, not fraud -- gets its own amber/informational
/// tone rather than the same red as a genuinely invalid code or a
/// network failure. An already-claimed-by-someone-else result also
/// gets a small profile card (initials avatar + name + workshop +
/// when) instead of just a sentence -- a specific, real-looking person
/// settles a false "I never got paid" complaint on the spot far better
/// than plain text does. Re-scanning your OWN already-claimed code
/// shows a plain message instead -- never a name card of yourself.
class ScanResultSurface extends StatelessWidget {
  const ScanResultSurface({
    super.key,
    required this.result,
    required this.onScanAnother,
  });

  final ScanResult result;
  final VoidCallback onScanAnother;

  static final _dateFormat = DateFormat('d MMM, h:mm a');

  @override
  Widget build(BuildContext context) {
    final success = result.isSuccess;
    final alreadyScanned =
        result.failureReason == ScanFailureReason.alreadyScanned;
    final showClaimCard =
        alreadyScanned &&
        !result.claimedByYou &&
        (result.claimedByName != null || result.claimedByWorkshop != null);
    final tone = success
        ? AppColors.success
        : alreadyScanned
        ? AppColors.warning
        : AppColors.error;

    return Container(
      color: AppColors.backgroundOf(context),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showClaimCard)
            _ClaimedReceiptCard(
              code: result.code,
              name: result.claimedByName,
              workshop: result.claimedByWorkshop,
              when: result.claimedAt != null
                  ? _dateFormat.format(result.claimedAt!.toLocal())
                  : null,
            )
          else ...[
            _Badge(glyph: success || alreadyScanned ? '✓' : '!', tone: tone),
            const SizedBox(height: AppSpacing.lg),
            if (success && result.rewardAmount != null)
              Text(
                '+Rs. ${result.rewardAmount}',
                style: GoogleFonts.sora(
                  color: AppColors.textOf(context),
                  fontWeight: FontWeight.w800,
                  fontSize: 36,
                ),
              )
            else
              Text(
                success
                    ? 'Reward added'
                    : alreadyScanned
                    ? 'Already scanned'
                    : "Couldn't add reward",
                style: TextStyle(
                  color: AppColors.textOf(context),
                  fontWeight: FontWeight.w800,
                  fontSize: 21,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              result.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.mutedTextOf(context),
                fontSize: 14.5,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          // Success stays the prominent, full-width action -- it's the
          // happy path, real money just moved. A retry (failure, or
          // "already claimed") is secondary and shouldn't compete with
          // that visually, so it's a compact outlined button instead
          // of the same full-bleed pill. Both buttons are content-sized
          // and centered (not edge-to-edge) -- the approved mockup's
          // overlay is a centered flex column, which hugs its
          // children's natural width rather than stretching them, and
          // the button just needs to match that natural size, not a
          // literal 100%. Explicit rounded-rectangle shape on both --
          // the app's Material 3 default for Filled/OutlinedButton is
          // a full stadium pill (used correctly everywhere else, e.g.
          // Submit/Withdraw Money), but the approved mockup for this
          // screen specifically used a boxier corner, matching the
          // 12px radius already established for cards/inputs in
          // app_theme.dart.
          if (success)
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: onScanAnother,
                style: FilledButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('Scan Another'),
              ),
            )
          else
            SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: onScanAnother,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textOf(context),
                  side: BorderSide(
                    color: AppColors.outlineOf(context),
                    width: 1.5,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('Try Again'),
              ),
            ),
        ],
      ),
    );
  }
}

/// A plain checkmark/exclamation glyph on a tinted circle -- see this
/// file's own doc comment for why it's text, not a Material icon.
class _Badge extends StatelessWidget {
  const _Badge({required this.glyph, required this.tone});

  final String glyph;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 44,
      backgroundColor: tone.withValues(alpha: 0.16),
      child: Text(
        glyph,
        style: TextStyle(
          color: tone,
          fontWeight: FontWeight.w800,
          fontSize: 40,
          height: 1,
        ),
      ),
    );
  }
}

/// Receipt-style card -- deliberately not an avatar/name "profile"
/// treatment (that read as a celebratory trophy card for what's
/// actually a block). Modeled on a real transaction/order lookup: a
/// dashed-off header naming the exact code, label/value rows for who
/// claimed it and when, and the outcome as its own footer strip. No
/// photo, no phone number -- see this file's own doc comment.
class _ClaimedReceiptCard extends StatelessWidget {
  const _ClaimedReceiptCard({
    required this.code,
    required this.name,
    required this.workshop,
    this.when,
  });

  final String? code;
  final String? name;
  final String? workshop;
  final String? when;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Already claimed',
            style: TextStyle(
              color: AppColors.textOf(context),
              fontWeight: FontWeight.w800,
              fontSize: 21,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerOf(context),
              border: Border.all(color: AppColors.outlineOf(context)),
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (code != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.outlineOf(context)),
                      ),
                    ),
                    child: Text(
                      code!,
                      style: TextStyle(
                        color: AppColors.mutedTextOf(context),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Column(
                    children: [
                      if (name != null) _ReceiptRow('Claimed by', name!),
                      if (workshop != null) _ReceiptRow('Workshop', workshop!),
                      if (when != null) _ReceiptRow('When', when!),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  color: AppColors.warning.withValues(alpha: 0.12),
                  child: Center(
                    child: Text(
                      '✕ Not eligible for reward',
                      style: TextStyle(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.mutedTextOf(context),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textOf(context),
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

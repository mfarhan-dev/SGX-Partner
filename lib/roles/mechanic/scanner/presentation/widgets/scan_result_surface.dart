import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../domain/scan_result.dart';

/// The scanner's own result overlay -- a solid dark background over
/// the paused camera preview (not translucent: a lower-alpha scrim let
/// the idle screen's own aiming-frame decoration show faintly through,
/// landing right behind the button and reading as a broken dialog),
/// told apart by icon/tone alone (same "color carries the state" rule
/// as WithdrawalStatusChip), with the credited amount in the same Sora
/// display face the Withdrawal Detail screen already uses for money.
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
      color: const Color(0xFF0B0B0D),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showClaimCard)
            _ClaimedByCard(
              name: result.claimedByName,
              workshop: result.claimedByWorkshop,
              when: result.claimedAt != null
                  ? _dateFormat.format(result.claimedAt!.toLocal())
                  : null,
            )
          else ...[
            CircleAvatar(
              radius: 32,
              backgroundColor: tone.withValues(alpha: 0.16),
              child: Icon(
                success
                    ? Icons.check_circle
                    : alreadyScanned
                    ? Icons.check_circle_outline
                    : Icons.error_outline,
                color: tone,
                size: 36,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (success && result.rewardAmount != null)
              Text(
                '+Rs. ${result.rewardAmount}',
                style: GoogleFonts.sora(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 30,
                ),
              )
            else
              Text(
                success ? 'Reward added' : "Couldn't add reward",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
            const SizedBox(height: 6),
            Text(
              result.message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 12.5),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          // Success stays the prominent, full-width action -- it's the
          // happy path, real money just moved. A retry (failure, or
          // "already claimed") is secondary and shouldn't compete with
          // that visually, so it's a compact outlined button instead
          // of the same full-bleed pill.
          if (success)
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onScanAnother,
                child: const Text('Scan Another'),
              ),
            )
          else
            OutlinedButton(
              onPressed: onScanAnother,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white38),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: 10,
                ),
              ),
              child: const Text('Try Again'),
            ),
        ],
      ),
    );
  }
}

class _ClaimedByCard extends StatelessWidget {
  const _ClaimedByCard({required this.name, required this.workshop, this.when});

  final String? name;
  final String? workshop;
  final String? when;

  @override
  Widget build(BuildContext context) {
    final displayName = name ?? workshop ?? 'Another mechanic';
    final initial = displayName.trim().isNotEmpty
        ? displayName.trim()[0].toUpperCase()
        : '?';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: const Text(
            'Already claimed',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // A colored-initial avatar, not a raw uploaded photo -- reads
        // as a real, specific person without needing a Storage policy
        // that would let any mechanic browse any other mechanic's
        // profile photo (see this widget's own doc comment).
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.warning.withValues(alpha: 0.22),
          child: Text(
            initial,
            style: const TextStyle(
              color: AppColors.warning,
              fontWeight: FontWeight.w800,
              fontSize: 22,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (name != null)
          Text(
            name!,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        if (workshop != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              workshop!,
              style: const TextStyle(color: Colors.white70, fontSize: 12.5),
            ),
          ),
        if (when != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              when!,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ),
      ],
    );
  }
}

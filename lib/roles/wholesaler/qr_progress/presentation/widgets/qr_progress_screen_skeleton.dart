import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../../../shared/widgets/skeleton.dart';

/// Loading placeholder shaped like the real QrProgressScreen (overall
/// stats card + a handful of batch cards) instead of a bare spinner in
/// the middle of an otherwise-blank screen -- same convention as
/// SettingsScreenSkeleton/LedgerScreenSkeleton.
class QrProgressScreenSkeleton extends StatelessWidget {
  const QrProgressScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _statsCardSkeleton(context),
        const SizedBox(height: AppSpacing.md),
        for (var i = 0; i < 3; i++) ...[
          _batchCardSkeleton(context),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }

  Widget _statsCardSkeleton(BuildContext context) {
    return Card(
      color: AppColors.surfaceContainerOf(context),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonBox(width: 110, height: 12),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(child: _statSkeleton()),
                Expanded(child: _statSkeleton()),
                Expanded(child: _statSkeleton()),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const SkeletonBox(width: double.infinity, height: 10, radius: 5),
          ],
        ),
      ),
    );
  }

  Widget _statSkeleton() {
    return Column(
      children: const [
        SkeletonBox(width: 36, height: 20),
        SizedBox(height: 6),
        SkeletonBox(width: 50, height: 11),
      ],
    );
  }

  Widget _batchCardSkeleton(BuildContext context) {
    return Card(
      color: AppColors.surfaceOf(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.outlineOf(context)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Row(
              children: [
                const SkeletonBox(width: 40, height: 40, radius: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SkeletonBox(width: 130, height: 13),
                      SizedBox(height: 6),
                      SkeletonBox(width: 70, height: 11),
                    ],
                  ),
                ),
                const SkeletonBox(width: 56, height: 24, radius: 12),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const SkeletonBox(width: double.infinity, height: 8, radius: 4),
          ],
        ),
      ),
    );
  }
}

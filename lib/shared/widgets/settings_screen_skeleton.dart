import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import 'skeleton.dart';

/// Full-screen loading placeholder for a partner Settings screen,
/// shaped like the real layout (header card, Account card, General
/// card) instead of a single spinner in one corner with the rest of
/// the screen showing "--" -- shared by both mechanic and wholesaler
/// Settings since their layouts are identical.
class SettingsScreenSkeleton extends StatelessWidget {
  const SettingsScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _headerSkeleton(),
        const SizedBox(height: AppSpacing.lg),
        const SkeletonBox(width: 80, height: 16),
        const SizedBox(height: AppSpacing.sm),
        _cardSkeleton(rows: 3),
        const SizedBox(height: AppSpacing.lg),
        const SkeletonBox(width: 80, height: 16),
        const SizedBox(height: AppSpacing.sm),
        _cardSkeleton(rows: 3),
        const SizedBox(height: AppSpacing.lg),
        const SkeletonBox(width: double.infinity, height: 48, radius: 12),
      ],
    );
  }

  Widget _headerSkeleton() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.surfaceContainer,
      ),
      child: Row(
        children: [
          const SkeletonBox(width: 64, height: 64, radius: 32),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonBox(width: 140, height: 16),
                SizedBox(height: AppSpacing.sm),
                SkeletonBox(width: 100, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardSkeleton({required int rows}) {
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < rows; i++) ...[
            if (i > 0) const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm + 4,
              ),
              child: Row(
                children: [
                  const SkeletonBox(width: 24, height: 24, radius: 6),
                  const SizedBox(width: AppSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SkeletonBox(width: 110, height: 13),
                      SizedBox(height: 6),
                      SkeletonBox(width: 70, height: 11),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

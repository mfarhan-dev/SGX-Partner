import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../../../shared/widgets/skeleton.dart';

/// Full-screen loading placeholder for WholesalerLedgerScreen, shaped
/// like the real layout (balance header, filter chips, date-grouped
/// rows) instead of a bare spinner over blank space -- its own class
/// and file, same pattern as SettingsScreenSkeleton.
class LedgerScreenSkeleton extends StatelessWidget {
  const LedgerScreenSkeleton({super.key, required this.topInset});

  /// Status-bar height so the skeleton header lines up exactly where
  /// the real gradient header (which runs edge-to-edge behind the
  /// status bar) starts -- no layout jump once the real data arrives.
  final double topInset;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _headerSkeleton(context),
        _filterRowSkeleton(),
        _entriesSkeleton(context),
      ],
    );
  }

  Widget _headerSkeleton(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        topInset + AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
      ),
      // The real header is a solid brand-color gradient -- kept
      // neutral here instead, same as Settings' own header skeleton
      // doesn't try to reproduce its gradient either.
      color: AppColors.surfaceContainerOf(context),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 60, height: 16),
          SizedBox(height: AppSpacing.md),
          SkeletonBox(width: 110, height: 12),
          SizedBox(height: 6),
          SkeletonBox(width: 160, height: 28),
        ],
      ),
    );
  }

  Widget _filterRowSkeleton() {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          SkeletonBox(width: 50, height: 32, radius: 999),
          SizedBox(width: AppSpacing.sm),
          SkeletonBox(width: 84, height: 32, radius: 999),
          SizedBox(width: AppSpacing.sm),
          SkeletonBox(width: 84, height: 32, radius: 999),
        ],
      ),
    );
  }

  Widget _entriesSkeleton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(width: 70, height: 11),
          const SizedBox(height: 10),
          for (var i = 0; i < 5; i++) ...[
            _rowSkeleton(),
            if (i != 4) const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }

  Widget _rowSkeleton() {
    return const Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 100, height: 13),
              SizedBox(height: 6),
              SkeletonBox(width: 70, height: 10),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SkeletonBox(width: 64, height: 13),
            SizedBox(height: 6),
            SkeletonBox(width: 54, height: 10),
          ],
        ),
      ],
    );
  }
}

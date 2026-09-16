import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../widgets/skeleton.dart';

/// Loading placeholder shaped like a saved payout account row (logo +
/// title/number + edit/delete icons) instead of a bare spinner --
/// shared by both mechanic and wholesaler Payout Method screens.
class PayoutAccountsSkeleton extends StatelessWidget {
  const PayoutAccountsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [for (var i = 0; i < 2; i++) _rowSkeleton(context)],
    );
  }

  Widget _rowSkeleton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerOf(context),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const SkeletonBox(width: 30, height: 30, radius: 15),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonBox(width: 90, height: 13),
                SizedBox(height: 6),
                SkeletonBox(width: 140, height: 11),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

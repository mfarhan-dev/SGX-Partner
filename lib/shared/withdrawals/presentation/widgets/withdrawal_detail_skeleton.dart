import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../widgets/skeleton.dart';

/// Loading placeholder shaped like the real Withdrawal Detail screen
/// (big centered amount, status chip, method/ref line, then a
/// timeline) instead of a bare spinner -- shared by both mechanic and
/// wholesaler detail screens, since their layouts are identical.
class WithdrawalDetailSkeleton extends StatelessWidget {
  const WithdrawalDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Center(
          child: Column(
            children: [
              SkeletonBox(width: 140, height: 36),
              SizedBox(height: AppSpacing.sm),
              SkeletonBox(width: 90, height: 24, radius: 12),
              SizedBox(height: AppSpacing.sm),
              SkeletonBox(width: 160, height: 13),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        for (var i = 0; i < 4; i++) _timelineStepSkeleton(i == 3),
      ],
    );
  }

  Widget _timelineStepSkeleton(bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              const SkeletonBox(width: 14, height: 14, radius: 7),
              if (!isLast)
                const Expanded(child: SkeletonBox(width: 2, height: 40)),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonBox(width: 130, height: 14),
                  SizedBox(height: 6),
                  SkeletonBox(width: 90, height: 11),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

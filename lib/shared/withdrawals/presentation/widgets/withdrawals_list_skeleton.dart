import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../widgets/skeleton.dart';

/// Loading placeholder shaped like the real Withdrawals list (a filter
/// chip row, then a handful of WithdrawalCard-shaped rows) instead of
/// a bare spinner -- shared by both mechanic and wholesaler screens,
/// since their layouts are identical.
class WithdrawalsListSkeleton extends StatelessWidget {
  const WithdrawalsListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            SkeletonBox(width: 70, height: 32, radius: 16),
            SizedBox(width: AppSpacing.sm),
            SkeletonBox(width: 80, height: 32, radius: 16),
            SizedBox(width: AppSpacing.sm),
            SkeletonBox(width: 110, height: 32, radius: 16),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        for (var i = 0; i < 4; i++) _rowSkeleton(),
      ],
    );
  }

  Widget _rowSkeleton() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            const SkeletonBox(width: 40, height: 40, radius: 20),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonBox(width: 90, height: 15),
                  SizedBox(height: 6),
                  SkeletonBox(width: 160, height: 11),
                  SizedBox(height: 4),
                  SkeletonBox(width: 130, height: 11),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const SkeletonBox(width: 56, height: 22, radius: 11),
          ],
        ),
      ),
    );
  }
}

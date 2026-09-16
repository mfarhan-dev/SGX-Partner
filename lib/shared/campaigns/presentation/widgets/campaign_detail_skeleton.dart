import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../widgets/skeleton.dart';

/// Loading placeholder shaped like the real Campaign Detail screen (a
/// 300px hero photo with rounded bottom corners, a stat row, and a
/// description block) instead of a bare spinner floating in empty
/// space below the hero's fixed offset. Mirrors ProductDetailSkeleton.
class CampaignDetailSkeleton extends StatelessWidget {
  const CampaignDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(28),
          ),
          child: SizedBox(
            height: 300,
            width: double.infinity,
            child: ColoredBox(color: AppColors.outlineOf(context)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Row(
                children: [
                  Expanded(
                    child: SkeletonBox(width: double.infinity, height: 48),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: SkeletonBox(width: double.infinity, height: 48),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.lg),
              SkeletonBox(width: 150, height: 15),
              SizedBox(height: AppSpacing.sm),
              SkeletonBox(width: double.infinity, height: 12),
              SizedBox(height: 6),
              SkeletonBox(width: double.infinity, height: 12),
              SizedBox(height: 6),
              SkeletonBox(width: 160, height: 12),
              SizedBox(height: AppSpacing.lg),
              SkeletonBox(width: 140, height: 15),
              SizedBox(height: AppSpacing.sm),
              SkeletonBox(width: double.infinity, height: 12),
              SizedBox(height: 8),
              SkeletonBox(width: double.infinity, height: 12),
              SizedBox(height: 8),
              SkeletonBox(width: double.infinity, height: 12),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../widgets/skeleton.dart';

/// Loading placeholder shaped like the real Product Detail screen (a
/// 300px hero photo with rounded bottom corners, a stock chip, and a
/// description block) instead of a bare spinner floating in empty
/// space below the hero's fixed offset.
class ProductDetailSkeleton extends StatelessWidget {
  const ProductDetailSkeleton({super.key});

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
              SkeletonBox(width: 90, height: 28, radius: 10),
              SizedBox(height: AppSpacing.md),
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
              SkeletonBox(width: 100, height: 15),
              SizedBox(height: AppSpacing.sm),
              SkeletonBox(width: double.infinity, height: 12),
              SizedBox(height: 6),
              SkeletonBox(width: double.infinity, height: 12),
              SizedBox(height: 6),
              SkeletonBox(width: 160, height: 12),
            ],
          ),
        ),
      ],
    );
  }
}

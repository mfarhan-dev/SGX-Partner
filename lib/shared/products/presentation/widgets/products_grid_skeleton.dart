import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../widgets/skeleton.dart';

/// Loading placeholder shaped like the real catalog grid (a photo
/// square + brand/name lines, same 2-column grid ProductTile renders
/// in) instead of a bare spinner over an otherwise-blank screen.
class ProductsGridSkeleton extends StatelessWidget {
  const ProductsGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.66,
      ),
      itemBuilder: (context, index) => _tileSkeleton(context),
    );
  }

  Widget _tileSkeleton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineOf(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: AspectRatio(
              aspectRatio: 1,
              child: ColoredBox(color: AppColors.outlineOf(context)),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 40, height: 9),
                SizedBox(height: 6),
                SkeletonBox(width: 90, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

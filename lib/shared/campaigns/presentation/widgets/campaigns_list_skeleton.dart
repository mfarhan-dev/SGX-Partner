import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';

/// Loading placeholder shaped like the real campaigns list -- a few
/// 16:9 photo-card silhouettes (CampaignTile's own aspect ratio)
/// instead of a bare spinner floating below the intro banner.
class CampaignsListSkeleton extends StatelessWidget {
  const CampaignsListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < 3; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ColoredBox(color: AppColors.outlineOf(context)),
              ),
            ),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../../../shared/widgets/skeleton.dart';

/// Loading placeholder shaped like the real Activity list (a date
/// label followed by a handful of rows, each with a title/subtitle and
/// a trailing amount) instead of a bare spinner -- same convention as
/// SettingsScreenSkeleton.
class WalletActivitySkeleton extends StatelessWidget {
  const WalletActivitySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: AppSpacing.sm, bottom: 6),
          child: SkeletonBox(width: 70, height: 11),
        ),
        for (var i = 0; i < 5; i++) _rowSkeleton(context),
      ],
    );
  }

  Widget _rowSkeleton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.outlineOf(context))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonBox(width: 140, height: 13),
                SizedBox(height: 6),
                SkeletonBox(width: 90, height: 11),
              ],
            ),
          ),
          const SkeletonBox(width: 50, height: 13),
        ],
      ),
    );
  }
}

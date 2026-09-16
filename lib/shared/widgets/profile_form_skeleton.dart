import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import 'skeleton.dart';

/// Loading placeholder shaped like the real profile edit forms
/// (MechanicProfileForm/WholesalerProfileForm -- an avatar picker
/// followed by several labeled text fields) instead of a bare spinner.
/// In practice this rarely renders: mechanicProfileDataProvider/
/// wholesalerProfileDataProvider are session-cached and Edit Profile
/// is only reached from Settings, which already fetched the same
/// provider -- this only shows on a genuinely cold load (e.g. a deep
/// link straight into Edit Profile).
class ProfileFormSkeleton extends StatelessWidget {
  const ProfileFormSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(child: SkeletonBox(width: 88, height: 88, radius: 44)),
        const SizedBox(height: AppSpacing.lg),
        for (var i = 0; i < 5; i++) ...[
          const SkeletonBox(width: 90, height: 11),
          const SizedBox(height: 6),
          const SkeletonBox(width: double.infinity, height: 44, radius: 10),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

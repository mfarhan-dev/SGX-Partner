import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import 'partner_avatar.dart';
import 'skeleton.dart';

/// AppBar-title greeting row shared by mechanic/wholesaler Home --
/// "Assalam-o-Alaikum" (static, per instruction) + the signed-in
/// partner's real name, with the same photo/initials fallback
/// (PartnerAvatar) as the Settings header, so the same person's
/// greeting never looks different between screens.
class PartnerGreeting extends StatelessWidget {
  const PartnerGreeting({super.key, required this.name, this.photoUrl});

  final String name;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PartnerAvatar(name: name, photoUrl: photoUrl, radius: 20),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assalam-o-Alaikum',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.mutedTextOf(context),
                ),
              ),
              Text(
                name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Loading placeholder for PartnerGreeting, same pulsing-skeleton
/// convention as SettingsScreenSkeleton -- shown only while there is no
/// cached profile yet (see each Home screen's AsyncValue.when()).
class PartnerGreetingSkeleton extends StatelessWidget {
  const PartnerGreetingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SkeletonBox(width: 40, height: 40, radius: 20),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SkeletonBox(width: 110, height: 11),
              SizedBox(height: 6),
              SkeletonBox(width: 140, height: 16),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../data/active_campaigns_providers.dart';
import '../../widgets/sgx_cards.dart';
import '../../widgets/sgx_screen.dart';
import 'widgets/campaigns_list_skeleton.dart';

class CampaignsScreen extends ConsumerWidget {
  const CampaignsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaignsAsync = ref.watch(activeCampaignsProvider);

    return SgxScreen(
      title: 'Campaigns',
      showNotifications: true,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerOf(context),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            children: [
              Icon(Icons.campaign_outlined, color: AppColors.primary),
              SizedBox(width: AppSpacing.sm),
              Expanded(child: Text('Active SGX promotions appear here.')),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        campaignsAsync.when(
          data: (campaigns) => campaigns.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      'No active campaigns right now.',
                      style: TextStyle(color: AppColors.mutedTextOf(context)),
                    ),
                  ),
                )
              : Column(
                  children: [
                    for (final campaign in campaigns)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: CampaignTile(campaign: campaign),
                      ),
                  ],
                ),
          loading: () => const CampaignsListSkeleton(),
          error: (error, stackTrace) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                'Could not load campaigns. Pull to refresh or try again later.',
                style: TextStyle(color: AppColors.mutedTextOf(context)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

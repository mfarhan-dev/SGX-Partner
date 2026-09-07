import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../data/active_campaigns_providers.dart';
import '../domain/active_campaign.dart';
import '../../widgets/sgx_screen.dart';

/// Reached from a real CampaignTile tap, so this reads from the same
/// activeCampaignsProvider list Home already fetched -- no second
/// network call. A campaign that isn't in that list any more (expired,
/// or the link is just stale) gets an honest "not found" state instead
/// of silently substituting a different campaign's details, which is
/// what the old mock-data lookup used to do.
class CampaignDetailScreen extends ConsumerWidget {
  const CampaignDetailScreen({super.key, required this.campaignId});

  final String campaignId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaignsAsync = ref.watch(activeCampaignsProvider);

    return SgxScreen(
      title: 'Campaign Detail',
      showBack: true,
      showNotifications: false,
      children: campaignsAsync.when(
        data: (campaigns) {
          ActiveCampaign? campaign;
          for (final item in campaigns) {
            if (item.id == campaignId) {
              campaign = item;
              break;
            }
          }
          if (campaign == null) return const [_CampaignNotFound()];
          return _content(context, campaign);
        },
        loading: () => const [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
        error: (error, stackTrace) => const [_CampaignNotFound()],
      ),
    );
  }

  List<Widget> _content(BuildContext context, ActiveCampaign campaign) {
    return [
      ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: campaign.imageUrl != null
            ? Image.network(
                campaign.imageUrl!,
                height: 190,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const _CampaignBannerPlaceholder(),
              )
            : const _CampaignBannerPlaceholder(),
      ),
      const SizedBox(height: AppSpacing.md),
      const Row(
        children: [
          Chip(
            avatar: Icon(Icons.bolt, size: 16),
            label: Text('Active campaign'),
            side: BorderSide.none,
            backgroundColor: AppColors.successContainer,
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.sm),
      Text(campaign.title, style: Theme.of(context).textTheme.headlineSmall),
      if (campaign.dateWindow.isNotEmpty) ...[
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            const Icon(Icons.calendar_month_outlined, size: 18),
            const SizedBox(width: 6),
            Text(campaign.dateWindow),
          ],
        ),
      ],
      if (campaign.prizeNote != null) ...[
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.warningContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.emoji_events_outlined, color: AppColors.warning),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  campaign.prizeNote!,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
      ],
      if (campaign.description != null) ...[
        const SizedBox(height: AppSpacing.lg),
        Text(
          'About this campaign',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          campaign.description!,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.mutedText,
            height: 1.5,
          ),
        ),
      ],
      const SizedBox(height: AppSpacing.lg),
      Text(
        'How to participate',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: AppSpacing.sm),
      const _StepLine(index: 1, text: 'Buy or install eligible SGX products.'),
      const _StepLine(
        index: 2,
        text: 'Use the app normally during the campaign.',
      ),
      const _StepLine(
        index: 3,
        text: 'Rewards are credited when confirmed by SGX.',
      ),
    ];
  }
}

class _CampaignBannerPlaceholder extends StatelessWidget {
  const _CampaignBannerPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      width: double.infinity,
      color: AppColors.primary.withValues(alpha: 0.08),
      child: const Center(
        child: Icon(
          Icons.campaign_outlined,
          size: 56,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _CampaignNotFound extends StatelessWidget {
  const _CampaignNotFound();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          const Icon(
            Icons.campaign_outlined,
            size: 40,
            color: AppColors.mutedText,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'This campaign is no longer available.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }
}

class _StepLine extends StatelessWidget {
  const _StepLine({required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.primary,
            child: Text('$index', style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

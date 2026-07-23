import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../mock/sgx_mock_data.dart';
import '../../widgets/sgx_screen.dart';

class CampaignDetailScreen extends StatelessWidget {
  const CampaignDetailScreen({super.key, required this.campaignId});

  final String campaignId;

  @override
  Widget build(BuildContext context) {
    final campaign = mockCampaigns.firstWhere(
      (item) => item.id == campaignId,
      orElse: () => mockCampaigns.first,
    );

    return SgxScreen(
      title: 'Campaign Detail',
      showBack: true,
      showNotifications: false,
      children: [
        Container(
          height: 190,
          decoration: BoxDecoration(
            color: campaign.tone.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(campaign.icon, size: 72, color: campaign.tone),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Chip(
              avatar: const Icon(Icons.bolt, size: 16),
              label: const Text('ACTIVE CAMPAIGN'),
              side: BorderSide.none,
              backgroundColor: AppColors.success.withValues(alpha: 0.12),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(campaign.title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            const Icon(Icons.calendar_month_outlined, size: 18),
            const SizedBox(width: 6),
            Text(campaign.dateWindow),
          ],
        ),
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
                  campaign.reward,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'About this campaign',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          campaign.description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.mutedText,
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'How to participate',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        const _StepLine(
          index: 1,
          text: 'Buy or install eligible SGX products.',
        ),
        const _StepLine(
          index: 2,
          text: 'Use the app normally during the campaign.',
        ),
        const _StepLine(
          index: 3,
          text: 'Rewards are credited when confirmed by SGX.',
        ),
      ],
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

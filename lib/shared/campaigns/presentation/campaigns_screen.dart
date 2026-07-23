import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../mock/sgx_mock_data.dart';
import '../../widgets/sgx_cards.dart';
import '../../widgets/sgx_screen.dart';

class CampaignsScreen extends StatelessWidget {
  const CampaignsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SgxScreen(
      title: 'Campaigns',
      showNotifications: true,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            children: [
              Icon(Icons.campaign_outlined, color: AppColors.primary),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Active SGX promotions appear here. Progress bars are not shown in v1.',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...mockCampaigns.map(
          (campaign) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: CampaignTile(campaign: campaign),
          ),
        ),
      ],
    );
  }
}

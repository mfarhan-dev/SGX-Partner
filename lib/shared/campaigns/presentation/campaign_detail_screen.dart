import '../../../shared/widgets/placeholder_screen.dart';

class CampaignDetailScreen extends PlaceholderScreen {
  const CampaignDetailScreen({super.key, required String campaignId})
    : super(
        title: 'Campaign Detail',
        description: 'Campaign details for campaign ID: $campaignId.',
      );
}

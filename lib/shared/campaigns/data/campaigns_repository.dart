import '../domain/campaign_models.dart';

abstract interface class CampaignsRepository {
  Future<List<CampaignSummary>> listCampaigns();

  Future<CampaignDetail> getCampaign(String campaignId);
}

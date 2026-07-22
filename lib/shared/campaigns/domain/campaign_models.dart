import '../../../shared/models/app_role.dart';

class CampaignSummary {
  const CampaignSummary({
    required this.id,
    required this.title,
    required this.description,
    required this.roles,
    required this.endsAt,
  });

  final String id;
  final String title;
  final String description;
  final Set<AppRole> roles;
  final DateTime endsAt;
}

class CampaignDetail extends CampaignSummary {
  const CampaignDetail({
    required super.id,
    required super.title,
    required super.description,
    required super.roles,
    required super.endsAt,
    required this.terms,
  });

  final String terms;
}

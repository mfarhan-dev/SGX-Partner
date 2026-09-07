import 'package:intl/intl.dart';

/// A currently-active campaign targeted at the signed-in partner's own
/// role, as returned by the get_active_campaigns() RPC -- already
/// filtered server-side (status = 'active', audience matches the
/// caller), so every row here is safe to show as-is.
class ActiveCampaign {
  const ActiveCampaign({
    required this.id,
    required this.title,
    this.description,
    this.prizeNote,
    this.startDate,
    this.endDate,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String? description;
  final String? prizeNote;
  final DateTime? startDate;
  final DateTime? endDate;

  /// Signed URL into the private campaign-images bucket -- time-limited,
  /// not something to cache past this session.
  final String? imageUrl;

  static final _dateFormat = DateFormat('d MMM y');

  /// "18 Jul - 28 Jul 2026" style, same shape the campaign cards have
  /// always shown -- blank when a campaign has no dates at all (both
  /// columns are null/non-null together, enforced by the database).
  String get dateWindow {
    if (startDate == null || endDate == null) return '';
    return '${_dateFormat.format(startDate!)} - ${_dateFormat.format(endDate!)}';
  }
}

import '../domain/qr_progress_models.dart';

abstract interface class WholesalerQrProgressRepository {
  Future<QrProgressSummary> loadSummary();

  Future<List<QrProgressItem>> listItems();
}

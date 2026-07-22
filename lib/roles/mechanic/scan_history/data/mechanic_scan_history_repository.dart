import '../domain/scan_history_item.dart';

abstract interface class MechanicScanHistoryRepository {
  Future<List<ScanHistoryItem>> listConfirmedScans();
}

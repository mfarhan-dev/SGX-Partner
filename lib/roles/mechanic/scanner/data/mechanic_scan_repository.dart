import '../domain/scan_result.dart';

abstract interface class MechanicScanRepository {
  Future<ScanResult> submitScan(String qrPayload);
}

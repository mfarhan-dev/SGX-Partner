import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'mechanic_scan_repository.dart';
import 'mechanic_scan_repository_impl.dart';

final mechanicScanRepositoryProvider = Provider<MechanicScanRepository>((ref) {
  return SupabaseMechanicScanRepository();
});

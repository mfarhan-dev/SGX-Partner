import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/auth/auth_controller.dart';
import '../domain/qr_progress_models.dart';

/// This wholesaler's real QR-code batch progress -- one row per
/// invoice line with QR codes, scoped server-side to this wholesaler
/// and to dispatched invoices only by get_wholesaler_qr_progress().
final wholesalerQrProgressProvider = FutureProvider<List<QrProgressBatch>>((
  ref,
) async {
  ref.watch(authControllerProvider);
  final client = Supabase.instance.client;

  final rows = await client.rpc('get_wholesaler_qr_progress') as List<dynamic>;
  return [for (final row in rows) _fromRow(row as Map<String, dynamic>)];
});

QrProgressBatch _fromRow(Map<String, dynamic> row) {
  return QrProgressBatch(
    invoiceLineId: row['invoice_line_id'] as String,
    invoiceNumber: row['invoice_number'] as String,
    productName: row['product_name'] as String,
    total: row['total'] as int,
    scanned: row['scanned'] as int,
    earned: row['earned'] as int,
  );
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/auth/auth_controller.dart';
import '../domain/khata_entry.dart';

/// Fetches the signed-in wholesaler's own khata ledger once per session
/// and caches it -- same reasoning as every other partner-data
/// provider in this app (mechanicProfileDataProvider,
/// activeCampaignsProvider, catalogProductsProvider): deliberately NOT
/// .autoDispose, since this tab is reached through a plain ShellRoute
/// that fully unmounts the previous tab's screen on every switch.
///
/// get_khata_ledger() already scopes to this caller's own
/// wholesaler_id server-side and orders by seq (newest first) -- the
/// current balance is just entries.first.balanceAfter, no separate
/// query needed.
final khataLedgerProvider = FutureProvider<List<KhataEntry>>((ref) async {
  ref.watch(authControllerProvider);
  final client = Supabase.instance.client;

  final rows = await client.rpc('get_khata_ledger') as List<dynamic>;

  return [for (final row in rows) _fromRow(row as Map<String, dynamic>)];
});

KhataEntry _fromRow(Map<String, dynamic> row) {
  return KhataEntry(
    id: row['id'] as String,
    entryType: row['entry_type'] as String,
    entryDate: DateTime.parse(row['entry_date'] as String),
    reference: row['reference'] as String?,
    note: row['note'] as String?,
    paymentMethod: row['payment_method'] as String?,
    debit: (row['debit'] as num?)?.toDouble(),
    credit: (row['credit'] as num?)?.toDouble(),
    balanceAfter: (row['balance_after'] as num).toDouble(),
  );
}

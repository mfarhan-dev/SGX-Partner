import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/auth/auth_controller.dart';
import '../domain/wallet_activity_entry.dart';

/// This mechanic's real activity feed -- QR reward credits and
/// withdrawal lifecycle events, unioned and ordered newest-first
/// server-side by get_mechanic_wallet_activity(). See that RPC's own
/// migration comment for exactly which rows a withdrawal can produce.
final mechanicWalletActivityProvider =
    FutureProvider<List<WalletActivityEntry>>((ref) async {
      ref.watch(authControllerProvider);
      final client = Supabase.instance.client;

      final rows =
          await client.rpc('get_mechanic_wallet_activity') as List<dynamic>;
      return [for (final row in rows) _fromRow(row as Map<String, dynamic>)];
    });

/// Real, never-decreasing lifetime-earned total (Rs.) -- summed
/// server-side by get_mechanic_wallet_summary() from every confirmed
/// QR-scan reward, unlike `points_balance` which is reduced the moment
/// a withdrawal is requested. Home only needs this one field from that
/// RPC's row; `available`/`pending` there already come from
/// mechanicProfileDataProvider/withdrawalsListProvider.
final mechanicLifetimeEarnedProvider = FutureProvider<int>((ref) async {
  ref.watch(authControllerProvider);
  final client = Supabase.instance.client;

  final rows = await client.rpc('get_mechanic_wallet_summary') as List<dynamic>;
  final row = rows.single as Map<String, dynamic>;
  return row['lifetime_earned'] as int;
});

WalletActivityEntry _fromRow(Map<String, dynamic> row) {
  return WalletActivityEntry(
    id: row['id'] as String,
    type: WalletEntryType.fromDb(row['entry_type'] as String),
    occurredAt: DateTime.parse(row['occurred_at'] as String),
    amount: row['amount'] as int?,
    withdrawalId: row['withdrawal_id'] as String?,
    reference: row['reference'] as String,
    note: row['note'] as String?,
  );
}

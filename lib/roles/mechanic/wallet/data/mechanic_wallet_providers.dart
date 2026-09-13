import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/auth/auth_controller.dart';
import '../domain/mechanic_wallet_summary.dart';
import '../domain/wallet_activity_entry.dart';

/// Real balances behind the mechanic Wallet screen, via
/// get_mechanic_wallet_summary() -- scoped to this caller's own
/// mechanic row server-side, same as every other partner RPC.
///
/// Deliberately NOT `.autoDispose`, same reasoning as every other
/// session-cached provider in this app (mechanicProfileDataProvider,
/// khataLedgerProvider, withdrawalsListProvider, ...): the Wallet tab
/// sits under a plain ShellRoute that fully unmounts on tab switch, so
/// autoDispose would silently refetch on every single visit.
final mechanicWalletSummaryProvider = FutureProvider<MechanicWalletSummary>((
  ref,
) async {
  ref.watch(authControllerProvider);
  final client = Supabase.instance.client;

  final rows = await client.rpc('get_mechanic_wallet_summary') as List<dynamic>;
  // Only empty if this session has no active mechanic profile at all
  // (shouldn't happen once signed in past onboarding) -- fall back to
  // zero rather than throwing, same spirit as MoneyAmount.zero elsewhere.
  if (rows.isEmpty) return MechanicWalletSummary.zero;

  final row = rows.first as Map<String, dynamic>;
  return MechanicWalletSummary(
    available: row['available'] as int,
    pending: row['pending'] as int,
    lifetimeEarned: row['lifetime_earned'] as int,
  );
});

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

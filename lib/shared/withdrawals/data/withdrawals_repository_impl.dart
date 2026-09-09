import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/withdrawal.dart';
import '../domain/withdrawal_method.dart';
import 'withdrawals_repository.dart';

/// Talks to the `withdrawals` table and its request_withdrawal() /
/// confirm_withdrawal_received() / dispute_withdrawal_received() /
/// get_withdrawal_settings() RPCs. Works for both mechanic and
/// wholesaler callers unmodified -- RLS on `withdrawals` already scopes
/// every read to the signed-in partner's own rows regardless of role,
/// and the RPCs resolve mechanic vs wholesaler from auth.uid() server-side.
class SupabaseWithdrawalsRepository implements WithdrawalsRepository {
  SupabaseWithdrawalsRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Future<List<Withdrawal>> listWithdrawals() async {
    final rows = await _client
        .from('withdrawals')
        .select()
        .order('requested_at', ascending: false);
    return rows.map(Withdrawal.fromRow).toList();
  }

  @override
  Future<Withdrawal> getWithdrawal(String withdrawalId) async {
    final row = await _client
        .from('withdrawals')
        .select()
        .eq('id', withdrawalId)
        .single();
    return Withdrawal.fromRow(row);
  }

  @override
  Future<Withdrawal> createWithdrawal({
    required int amountRupees,
    required WithdrawalMethod method,
    required String accountTitle,
    required String accountNumber,
  }) async {
    final row = await _client
        .rpc(
          'request_withdrawal',
          params: {
            'p_amount': amountRupees,
            'p_method': method.dbValue,
            'p_account_title': accountTitle,
            'p_account_number': accountNumber,
          },
        )
        .single();
    return Withdrawal.fromRow(row);
  }

  @override
  Future<Withdrawal> confirmReceived(String withdrawalId) async {
    final row = await _client
        .rpc(
          'confirm_withdrawal_received',
          params: {'p_withdrawal_id': withdrawalId},
        )
        .single();
    return Withdrawal.fromRow(row);
  }

  @override
  Future<Withdrawal> disputeReceived(String withdrawalId, String reason) async {
    final row = await _client
        .rpc(
          'dispute_withdrawal_received',
          params: {'p_withdrawal_id': withdrawalId, 'p_reason': reason},
        )
        .single();
    return Withdrawal.fromRow(row);
  }

  @override
  Future<int> getMinWithdrawalAmount() async {
    final row = await _client.rpc('get_withdrawal_settings').single();
    return (row['min_withdrawal_amount'] as num).toInt();
  }
}

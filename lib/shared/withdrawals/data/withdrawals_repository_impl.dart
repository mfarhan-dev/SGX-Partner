import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/payout_account.dart';
import '../domain/payout_provider.dart';
import '../domain/withdrawal.dart';
import 'withdrawals_repository.dart';

/// Talks to the `withdrawals` / `payout_accounts` tables and their
/// request_withdrawal() / confirm_withdrawal_received() /
/// dispute_withdrawal_received() / get_withdrawal_settings() /
/// add_payout_account() / update_payout_account() /
/// delete_payout_account() RPCs. Works for both mechanic and
/// wholesaler callers unmodified -- RLS already
/// scopes every read to the signed-in partner's own rows regardless of
/// role, and the RPCs resolve mechanic vs wholesaler from auth.uid()
/// server-side.
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
    String? payoutAccountId,
  }) async {
    final row = await _client
        .rpc(
          'request_withdrawal',
          params: {
            'p_amount': amountRupees,
            'p_payout_account_id': payoutAccountId,
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

  @override
  Future<List<PayoutAccount>> listPayoutAccounts() async {
    final rows = await _client
        .from('payout_accounts')
        .select()
        .order('created_at');
    return rows.map(PayoutAccount.fromRow).toList();
  }

  @override
  Future<PayoutAccount> addPayoutAccount({
    required PayoutProvider provider,
    required String accountTitle,
    required String accountNumber,
  }) async {
    final row = await _client
        .rpc(
          'add_payout_account',
          params: {
            'p_provider': provider.id,
            'p_account_title': accountTitle,
            'p_account_number': accountNumber,
          },
        )
        .single();
    return PayoutAccount.fromRow(row);
  }

  @override
  Future<PayoutAccount> updatePayoutAccount({
    required String accountId,
    required String accountTitle,
    required String accountNumber,
  }) async {
    final row = await _client
        .rpc(
          'update_payout_account',
          params: {
            'p_account_id': accountId,
            'p_account_title': accountTitle,
            'p_account_number': accountNumber,
          },
        )
        .single();
    return PayoutAccount.fromRow(row);
  }

  @override
  Future<void> deletePayoutAccount(String accountId) async {
    await _client.rpc(
      'delete_payout_account',
      params: {'p_account_id': accountId},
    );
  }
}

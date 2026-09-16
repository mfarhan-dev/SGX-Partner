import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_controller.dart';
import '../domain/payout_account.dart';
import '../domain/withdrawal.dart';
import '../domain/withdrawal_dispute_event.dart';
import '../domain/withdrawal_payment_event.dart';
import 'withdrawals_repository.dart';
import 'withdrawals_repository_impl.dart';

final withdrawalsRepositoryProvider = Provider<WithdrawalsRepository>((ref) {
  return SupabaseWithdrawalsRepository();
});

/// This partner's own withdrawal history -- one shared provider works
/// for both mechanic and wholesaler callers unmodified, since RLS on
/// `withdrawals` already scopes the read to whichever role is signed in.
///
/// Deliberately NOT `.autoDispose`, same reasoning as every other
/// session-cached provider in this app (mechanicProfileDataProvider,
/// khataLedgerProvider, ...): the Withdrawals tab sits under a plain
/// ShellRoute that fully unmounts on tab switch, so autoDispose would
/// silently refetch on every single visit instead of caching for the
/// session.
///
/// Refetch by calling `ref.invalidate(withdrawalsListProvider)` right
/// after a successful request/confirm/dispute -- same pattern used
/// after a profile edit elsewhere in this app.
final withdrawalsListProvider = FutureProvider<List<Withdrawal>>((ref) async {
  ref.watch(authControllerProvider);
  final repository = ref.watch(withdrawalsRepositoryProvider);
  return repository.listWithdrawals();
});

/// A single withdrawal's live detail, by id. `.autoDispose` here is
/// correct (unlike the list above): the detail screen always wants the
/// freshest status right after a confirm/dispute action, not a
/// session-cached snapshot, and it is reached by push rather than as a
/// persistent tab.
final withdrawalDetailProvider = FutureProvider.autoDispose
    .family<Withdrawal, String>((ref, withdrawalId) async {
      final repository = ref.watch(withdrawalsRepositoryProvider);
      return repository.getWithdrawal(withdrawalId);
    });

/// Rs. minimum withdrawal amount, from app_settings via
/// get_withdrawal_settings(). Session-cached like the profile providers
/// -- this practically never changes mid-session.
final minWithdrawalAmountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(withdrawalsRepositoryProvider);
  return repository.getMinWithdrawalAmount();
});

/// Signed URL for one withdrawal's payment-proof screenshot, keyed by
/// its raw storage path (Withdrawal.proofStoragePath). `.autoDispose`
/// + `.family` -- only ever watched from the Detail screen for
/// whichever withdrawal is open, never needed on Home or the list.
final withdrawalProofUrlProvider = FutureProvider.autoDispose
    .family<String?, String>((ref, storagePath) async {
      final repository = ref.watch(withdrawalsRepositoryProvider);
      return repository.getProofImageUrl(storagePath);
    });

/// This withdrawal's full "marked paid" history, oldest first --
/// normally one entry, more than one only after a dispute got
/// re-paid. `.autoDispose` + `.family`, same reasoning as
/// [withdrawalProofUrlProvider]: only ever watched from the Detail
/// screen for whichever withdrawal is open.
final withdrawalPaymentEventsProvider = FutureProvider.autoDispose
    .family<List<WithdrawalPaymentEvent>, String>((ref, withdrawalId) async {
      final repository = ref.watch(withdrawalsRepositoryProvider);
      return repository.getPaymentEvents(withdrawalId);
    });

/// This withdrawal's full dispute history, oldest first -- normally
/// one entry, more than one only when a re-paid withdrawal got
/// disputed again. Mirrors [withdrawalPaymentEventsProvider] exactly.
final withdrawalDisputeEventsProvider = FutureProvider.autoDispose
    .family<List<WithdrawalDisputeEvent>, String>((ref, withdrawalId) async {
      final repository = ref.watch(withdrawalsRepositoryProvider);
      return repository.getDisputeEvents(withdrawalId);
    });

/// Every payout account the signed-in partner has saved, oldest-added
/// first -- one shared provider for both roles, same reasoning as
/// [withdrawalsListProvider] (session-cached, not `.autoDispose`;
/// invalidate after any add/edit/delete so Settings and the Withdraw
/// Money sheet both see the change immediately). There's no "default"
/// concept -- insertion order IS the order shown everywhere, straight
/// from the repository (which already orders by created_at).
final payoutAccountsProvider = FutureProvider<List<PayoutAccount>>((ref) async {
  ref.watch(authControllerProvider);
  final repository = ref.watch(withdrawalsRepositoryProvider);
  return repository.listPayoutAccounts();
});

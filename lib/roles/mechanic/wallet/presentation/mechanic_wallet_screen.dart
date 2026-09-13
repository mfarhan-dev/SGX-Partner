import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/sgx_app_bar.dart';
import '../data/mechanic_wallet_providers.dart';
import '../domain/wallet_activity_entry.dart';

enum _WalletFilter { all, rewards, withdrawals }

/// Real Activity screen -- replaces the mocked "Recent Activity" list
/// (MockTransaction) with get_mechanic_wallet_activity(). See
/// handoff.md gap #1: this was the single most visible remaining mock
/// screen in the app, still shown to a real signed-in mechanic today.
///
/// This is a pure log -- what happened and when, nothing more. It
/// deliberately does NOT repeat the balance card or the Withdraw Money
/// button: those already live on Home (WalletHeroCard), and a
/// withdrawal row here already pushes straight to the existing
/// Withdrawal Detail screen for anything beyond a one-line summary
/// (proof screenshots, re-pay history, dispute actions).
class MechanicWalletScreen extends ConsumerStatefulWidget {
  const MechanicWalletScreen({super.key});

  @override
  ConsumerState<MechanicWalletScreen> createState() =>
      _MechanicWalletScreenState();
}

class _MechanicWalletScreenState extends ConsumerState<MechanicWalletScreen> {
  _WalletFilter _filter = _WalletFilter.all;
  static final _dateFormat = DateFormat('d MMM y');

  @override
  Widget build(BuildContext context) {
    final activityAsync = ref.watch(mechanicWalletActivityProvider);

    // A scan or a withdrawal status change can happen from outside this
    // app (admin/staff side, or the mechanic scanning right before
    // opening this tab) far more often than session-cached data usually
    // changes -- same reasoning, and same fix, as wholesaler's ledger
    // screen: pull-to-refresh actually has to refetch, not just re-read
    // the cached Future.
    Future<void> refresh() async {
      ref.invalidate(mechanicWalletActivityProvider);
      await ref.read(mechanicWalletActivityProvider.future);
    }

    return Scaffold(
      appBar: const SgxAppBar(title: 'Activity'),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              _filterRow(),
              const SizedBox(height: AppSpacing.sm),
              activityAsync.when(
                data: (entries) => _activityList(context, entries),
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: AppSpacing.xl),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stackTrace) => Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xl),
                  child: Center(
                    child: Text(
                      'Could not load your activity. Pull to refresh or try again later.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.mutedTextOf(context)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterRow() {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _WalletFilter.values.map((filter) {
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ChoiceChip(
              label: Text(_labelFor(filter)),
              selected: _filter == filter,
              onSelected: (_) => setState(() => _filter = filter),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _labelFor(_WalletFilter filter) => switch (filter) {
    _WalletFilter.all => 'All',
    _WalletFilter.rewards => 'Rewards',
    _WalletFilter.withdrawals => 'Withdrawals',
  };

  bool _matchesFilter(WalletActivityEntry entry) => switch (_filter) {
    _WalletFilter.all => true,
    _WalletFilter.rewards => entry.type == WalletEntryType.qrReward,
    _WalletFilter.withdrawals => entry.isWithdrawalEvent,
  };

  Widget _activityList(BuildContext context, List<WalletActivityEntry> all) {
    final entries = all.where(_matchesFilter).toList();

    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xl),
        child: Center(
          child: Text(
            'No activity found',
            style: TextStyle(color: AppColors.mutedTextOf(context)),
          ),
        ),
      );
    }

    // Group by calendar date, preserving the newest-first order the
    // RPC already returned -- same presentation as the wholesaler
    // ledger screen.
    final groups = <DateTime, List<WalletActivityEntry>>{};
    for (final entry in entries) {
      final day = DateTime(
        entry.occurredAt.year,
        entry.occurredAt.month,
        entry.occurredAt.day,
      );
      groups.putIfAbsent(day, () => []).add(entry);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final day in groups.keys) ...[
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: 6),
            child: Text(
              _dateFormat.format(day),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.mutedTextOf(context),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
          for (final entry in groups[day]!) _ActivityRow(entry: entry),
        ],
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.entry});

  final WalletActivityEntry entry;

  static final _amountFormat = NumberFormat.currency(
    symbol: 'Rs. ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final amount = entry.amount;
    final isCredit = (amount ?? 0) > 0;

    return InkWell(
      // Card taps use push (not go) so back-navigation works -- same
      // rule as everywhere else in this app. Only withdrawal rows push
      // anywhere; a QR reward row has nothing further to show.
      onTap: entry.withdrawalId == null
          ? null
          : () => context.push('/mechanic/withdrawals/${entry.withdrawalId}'),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.outlineOf(context)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _titleFor(entry.type),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                      color: AppColors.textOf(context),
                    ),
                  ),
                  if (_subtitleFor(entry) != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      _subtitleFor(entry)!,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.mutedTextOf(context),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (amount != null)
              Text(
                '${isCredit ? '+' : '−'}${_amountFormat.format(amount.abs())}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: isCredit ? AppColors.success : AppColors.error,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _titleFor(WalletEntryType type) => switch (type) {
    WalletEntryType.qrReward => 'QR reward added',
    WalletEntryType.withdrawalRequested => 'Withdrawal requested',
    WalletEntryType.paymentSent => 'Payment sent',
    WalletEntryType.withdrawalConfirmed => 'Withdrawal confirmed',
    WalletEntryType.withdrawalAutoConfirmed => 'Withdrawal auto-confirmed',
    WalletEntryType.withdrawalDisputed => 'Withdrawal disputed',
    WalletEntryType.withdrawalRefunded => 'Money returned to wallet',
  };

  String? _subtitleFor(WalletActivityEntry entry) => switch (entry.type) {
    // The scanned product name, when known.
    WalletEntryType.qrReward => entry.note,
    // A dispute reason matters more than the bare withdrawal number.
    WalletEntryType.withdrawalDisputed => entry.note ?? entry.reference,
    _ => entry.reference,
  };
}

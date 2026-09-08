import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../data/khata_ledger_providers.dart';
import '../domain/khata_entry.dart';

enum _LedgerFilter { all, purchases, payments }

/// Real khata ledger via get_khata_ledger() -- replaces the mocked
/// "Activity" tab, wholesaler-only (khata_entries has no mechanic
/// relationship at all). One colored amount per row, not separate
/// debit/credit columns -- which one applies is read straight off
/// which of the row's own debit/credit columns is populated. The
/// running balance the database already computes is shown under each
/// amount, so nothing is recalculated client-side.
///
/// The balance card runs edge-to-edge behind the status bar with white
/// icons (AnnotatedRegion) -- same treatment as the campaign/product
/// hero photos, applied here since "Ledger" as a separate plain title
/// bar above a colored card was the same boxed-in look already fixed
/// there.
class WholesalerLedgerScreen extends ConsumerStatefulWidget {
  const WholesalerLedgerScreen({super.key});

  @override
  ConsumerState<WholesalerLedgerScreen> createState() =>
      _WholesalerLedgerScreenState();
}

class _WholesalerLedgerScreenState
    extends ConsumerState<WholesalerLedgerScreen> {
  _LedgerFilter _filter = _LedgerFilter.all;
  static final _dateFormat = DateFormat('d MMM y');
  static final _amountFormat = NumberFormat.currency(
    symbol: 'Rs. ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final ledgerAsync = ref.watch(khataLedgerProvider);
    final topInset = MediaQuery.of(context).padding.top;

    // A khata ledger changes from the staff/admin side, outside this
    // app, far more often than a mechanic's or wholesaler's own
    // profile does -- and khataLedgerProvider is deliberately session-
    // cached (see the provider file), so without this there was no way
    // to ever see a new entry short of restarting the app. The error
    // state's own text already promised "pull to refresh"; this is
    // what actually makes that true.
    Future<void> refresh() async {
      ref.invalidate(khataLedgerProvider);
      await ref.read(khataLedgerProvider.future);
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: SafeArea(
          top: false,
          child: RefreshIndicator(
            onRefresh: refresh,
            child: ledgerAsync.when(
              data: (entries) => _content(context, entries, topInset),
              loading: () => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(top: topInset + 140),
                child: const Center(child: CircularProgressIndicator()),
              ),
              error: (error, stackTrace) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(top: topInset + 96),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Text(
                      'Could not load your ledger. Pull to refresh or try again later.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.mutedTextOf(context)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(
    BuildContext context,
    List<KhataEntry> entries,
    double topInset,
  ) {
    final filtered = entries.where((entry) {
      return switch (_filter) {
        _LedgerFilter.all => true,
        _LedgerFilter.purchases => entry.isDebit,
        _LedgerFilter.payments => !entry.isDebit,
      };
    }).toList();

    final balance = entries.isNotEmpty ? entries.first.balanceAfter : 0.0;
    final owesSgx = balance > 0;

    // Group by calendar date, preserving the newest-first order the
    // RPC already returned.
    final groups = <DateTime, List<KhataEntry>>{};
    for (final entry in filtered) {
      final day = DateTime(
        entry.entryDate.year,
        entry.entryDate.month,
        entry.entryDate.day,
      );
      groups.putIfAbsent(day, () => []).add(entry);
    }

    return ListView(
      // So the pull-to-refresh gesture works even when there are few
      // enough entries that the list is shorter than the screen.
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            topInset + AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.md,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ledger',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                owesSgx ? 'You owe SGX' : 'Credit balance',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _amountFormat.format(balance.abs()),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            0,
          ),
          child: Row(
            children: [
              _FilterChip(
                label: 'All',
                selected: _filter == _LedgerFilter.all,
                onTap: () => setState(() => _filter = _LedgerFilter.all),
              ),
              const SizedBox(width: AppSpacing.sm),
              _FilterChip(
                label: 'Purchases',
                selected: _filter == _LedgerFilter.purchases,
                onTap: () => setState(() => _filter = _LedgerFilter.purchases),
              ),
              const SizedBox(width: AppSpacing.sm),
              _FilterChip(
                label: 'Payments',
                selected: _filter == _LedgerFilter.payments,
                onTap: () => setState(() => _filter = _LedgerFilter.payments),
              ),
            ],
          ),
        ),
        if (groups.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 64),
            child: Center(
              child: Text(
                'No ledger entries found.',
                style: TextStyle(color: AppColors.mutedTextOf(context)),
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final day in groups.keys) ...[
                  Padding(
                    padding: const EdgeInsets.only(
                      top: AppSpacing.md,
                      bottom: 6,
                    ),
                    child: Text(
                      _dateFormat.format(day),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.mutedTextOf(context),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  for (final entry in groups[day]!)
                    _LedgerRow(entry: entry, amountFormat: _amountFormat),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          // Solid "ink" pill for the selected state -- has to flip
          // with the theme (dark pill in light mode, light pill in
          // dark mode) via textOf(), not the plain .text literal,
          // which stayed near-black even in dark mode and nearly
          // vanished against the dark page background.
          color: selected
              ? AppColors.textOf(context)
              : AppColors.surfaceOf(context),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? AppColors.textOf(context)
                : AppColors.outlineOf(context),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            // The pill's own background color, inverted -- keeps the
            // label legible whichever way textOf() resolved above.
            color: selected
                ? AppColors.backgroundOf(context)
                : AppColors.mutedTextOf(context),
          ),
        ),
      ),
    );
  }
}

class _LedgerRow extends StatelessWidget {
  const _LedgerRow({required this.entry, required this.amountFormat});

  final KhataEntry entry;
  final NumberFormat amountFormat;

  @override
  Widget build(BuildContext context) {
    final color = entry.isDebit ? AppColors.error : AppColors.success;
    final sign = entry.isDebit ? '+' : '−';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.outlineOf(context))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.description,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                    color: AppColors.textOf(context),
                  ),
                ),
                if (entry.reference != null || entry.paymentMethod != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    [
                      entry.paymentMethod,
                      entry.reference,
                    ].where((part) => part != null).join(' · '),
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.mutedTextOf(context),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$sign${amountFormat.format(entry.amount)}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: color,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                'Bal: ${amountFormat.format(entry.balanceAfter)}',
                style: TextStyle(
                  fontSize: 10.5,
                  color: AppColors.mutedTextOf(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

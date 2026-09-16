import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/campaigns/data/active_campaigns_providers.dart';
import '../../../../shared/models/money_amount.dart';
import '../../../../shared/notifications/data/notifications_providers.dart';
import '../../../../shared/widgets/partner_greeting.dart';
import '../../../../shared/widgets/sgx_cards.dart';
import '../../../../shared/withdrawals/data/withdrawals_providers.dart';
import '../../../../shared/withdrawals/presentation/widgets/withdrawal_activity_card.dart';
import '../../profile/data/wholesaler_profile_providers.dart';
import '../../wallet/data/khata_ledger_providers.dart';
import '../../withdrawals/presentation/wholesaler_withdraw_money_screen.dart';

class WholesalerHomeScreen extends ConsumerWidget {
  const WholesalerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Same wholesalerProfileDataProvider Settings already fetches once
    // per session -- reused here so Home shows the real signed-in
    // person instead of the old hardcoded "Muhammad Farhan" mock.
    final profileAsync = ref.watch(wholesalerProfileDataProvider);
    final campaignsAsync = ref.watch(activeCampaignsProvider);
    final withdrawalsAsync = ref.watch(withdrawalsListProvider);
    final minAmountAsync = ref.watch(minWithdrawalAmountProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider).value ?? 0;
    final lifetimeEarnedAsync = ref.watch(wholesalerLifetimeEarnedProvider);

    // Real running balance -- credited the instant a mechanic scans a
    // QR code tied to one of this wholesaler's invoices (see
    // scan_qr_code()/credit_points_on_qr_scan on the database side),
    // never summed client-side. Rupees on the wire, converted to
    // MoneyAmount's cents.
    final pointsBalance = profileAsync.value?.pointsBalance ?? 0;
    final available = MoneyAmount(cents: pointsBalance * 100);

    // "Pending" is real now: the sum of withdrawals already deducted
    // from points_balance (request_withdrawal() deducts immediately)
    // but not yet finalized -- i.e. every non-terminal status.
    final withdrawals = withdrawalsAsync.value ?? const [];
    final pendingCents = withdrawals
        .where((w) => !w.status.isTerminal)
        .fold<int>(0, (sum, w) => sum + w.amount.cents);
    final pending = MoneyAmount(cents: pendingCents);

    // Real, never-decreasing lifetime total from
    // get_wholesaler_wallet_summary() -- falls back to `available` only
    // while the RPC is still loading/erroring, so the card never shows
    // a blank or a lifetime total lower than what's actually available.
    final lifetime = lifetimeEarnedAsync.maybeWhen(
      data: (rupees) => MoneyAmount(cents: rupees * 100),
      orElse: () => available,
    );

    // The single most recent non-terminal withdrawal, if any -- shown
    // as Home's status banner. Nothing renders here until this partner
    // has actually requested a withdrawal. withdrawalsListProvider
    // already orders newest-first, so this is simply the first match.
    final nonTerminal = withdrawals.where((w) => !w.status.isTerminal);
    final activeWithdrawal = nonTerminal.isEmpty ? null : nonTerminal.first;

    return Scaffold(
      appBar: AppBar(
        title: profileAsync.when(
          data: (profile) => PartnerGreeting(
            name: profile.ownerName,
            photoUrl: profile.photoUrl,
          ),
          loading: () => const PartnerGreetingSkeleton(),
          // A failed fetch here shouldn't block the whole Home screen
          // the way it would on Settings -- fall back to a neutral
          // greeting instead of an error banner over the wallet.
          error: (error, stackTrace) => const PartnerGreeting(name: 'Partner'),
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            // No separate Notifications screen -- every notification
            // type wired up so far already duplicates a row Activity
            // shows, so the bell just badges "something happened" and
            // goes straight to Activity (a tab, hence go() not push()),
            // marking everything read on the way.
            onPressed: () {
              markAllNotificationsRead(ref);
              context.go('/wholesaler/wallet');
            },
            icon: Badge(
              isLabelVisible: unreadCount > 0,
              label: Text('$unreadCount'),
              child: const Icon(Icons.notifications_outlined),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            WalletHeroCard(
              available: available,
              pending: pending,
              lifetime: lifetime,
              loading: profileAsync.isLoading,
              minWithdrawalAmount: minAmountAsync.value,
              onWithdraw: () => showWholesalerWithdrawMoneySheet(context, ref),
              compact: true,
            ),
            if (activeWithdrawal != null) ...[
              const SizedBox(height: AppSpacing.md),
              WithdrawalActivityCard(
                withdrawal: activeWithdrawal,
                routePrefix: '/wholesaler/withdrawals',
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            CampaignCarousel(campaigns: campaignsAsync.value ?? const []),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/utils/money_formatter.dart';
import '../campaigns/domain/active_campaign.dart';
import '../models/money_amount.dart';
import '../products/domain/catalog_product.dart';
import '../withdrawals/domain/withdrawal.dart';
import '../withdrawals/domain/withdrawal_status.dart';

class WalletHeroCard extends StatelessWidget {
  const WalletHeroCard({
    super.key,
    required this.available,
    required this.pending,
    required this.lifetime,
    required this.onWithdraw,
    this.minWithdrawalAmount,
    this.compact = false,
    this.loading = false,
  });

  final MoneyAmount available;
  final MoneyAmount pending;
  final MoneyAmount lifetime;
  final VoidCallback onWithdraw;

  /// True while the real balance hasn't loaded yet -- swaps the amount
  /// texts for glass-tinted skeleton boxes instead of showing "Rs. 0"
  /// (which reads as a real, alarming zero balance rather than "still
  /// loading"). The branded card shell itself (gradient, icons, static
  /// labels, the button) stays fully real throughout, since none of
  /// that is actually loading -- only the three numbers are.
  final bool loading;

  /// Rs. minimum from app_settings, via minWithdrawalAmountProvider --
  /// shown as a quiet, always-visible caption under the button, never
  /// used to disable it. A disabled button here would tell a partner
  /// nothing about *why* (Nielsen Norman Group's own guidance: disabled
  /// buttons "confuse users by appearing clickable but providing no
  /// response or feedback"), which matters even more for a first-time,
  /// possibly-low-literacy audience. The Withdraw Money sheet this
  /// button opens already validates the amount properly -- tapping
  /// Continue below the minimum shows a clear, readable inline message
  /// there ("Minimum withdrawal amount is Rs. 100.") instead of a
  /// fleeting toast. One clear explanation, in one place, always
  /// reachable.
  final int? minWithdrawalAmount;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.24),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned(
            right: -12,
            top: -16,
            child: Icon(
              Icons.account_balance_wallet,
              color: Color(0x18FFFFFF),
              size: 150,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 22,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Available Balance',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              loading
                  ? _WhiteSkeletonBox(width: 150, height: compact ? 38 : 44)
                  : Text(
                      MoneyFormatter.format(available),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: compact ? 38 : 44,
                        height: 1.05,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _GlassValue(
                      label: 'PENDING',
                      value: MoneyFormatter.format(pending),
                      loading: loading,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _GlassValue(
                      label: 'LIFETIME',
                      value: MoneyFormatter.format(lifetime),
                      loading: loading,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                  ),
                  onPressed: onWithdraw,
                  icon: const Icon(Icons.payments_outlined),
                  label: const Text('Withdraw Money'),
                ),
              ),
              if (minWithdrawalAmount != null) ...[
                const SizedBox(height: 6),
                Text(
                  'Minimum Rs. $minWithdrawalAmount per withdrawal',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _GlassValue extends StatelessWidget {
  const _GlassValue({
    required this.label,
    required this.value,
    this.loading = false,
  });

  final String label;
  final String value;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 2),
          loading
              ? const _WhiteSkeletonBox(width: 60, height: 15)
              : Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
        ],
      ),
    );
  }
}

/// A static, glass-tinted white box standing in for a number that
/// hasn't loaded yet -- used only against WalletHeroCard's own colored
/// gradient, where the shared grey SkeletonBox (tuned for a plain
/// surface) would look wrong. Unanimated by design: this card's own
/// numbers resolve almost immediately (session-cached provider), so a
/// brief static placeholder reads cleaner than adding motion for a
/// fraction of a second.
class _WhiteSkeletonBox extends StatelessWidget {
  const _WhiteSkeletonBox({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

/// Grid card for the real product catalog -- a large square photo (or
/// a plain placeholder when a product has none uploaded yet) taking
/// most of the card, brand, name, and a small in-stock indicator dot.
/// No price anywhere: get_catalog_products() doesn't return one, per
/// instruction. Modeled on Faire Wholesale's own B2B catalog grid --
/// the closest real reference for "one photo card, wholesale ordering
/// context" of everything checked.
class ProductTile extends StatelessWidget {
  const ProductTile({super.key, required this.product});

  final CatalogProduct product;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      // push, not go: go() replaces the route with no back stack behind
      // it, which is exactly why back from the detail screen was
      // landing on Home instead of returning to this grid. push()
      // actually keeps this screen underneath, so back returns here.
      onTap: () => context.push('/products/${product.id}'),
      child: Ink(
        decoration: BoxDecoration(
          color: AppColors.surfaceOf(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outlineOf(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child: product.imageUrl != null
                    ? Image.network(
                        product.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _placeholder(context),
                      )
                    : _placeholder(context),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.brand != null) ...[
                    Text(
                      product.brand!.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.titleSmall?.copyWith(height: 1.25),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: product.inStock
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        product.inStock ? 'In stock' : 'Out of stock',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedTextOf(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _placeholder(BuildContext context) {
    return Container(
      color: AppColors.surfaceContainerOf(context),
      child: Center(
        child: Icon(
          Icons.inventory_2_outlined,
          size: 36,
          color: AppColors.mutedTextOf(context),
        ),
      ),
    );
  }
}

/// Full-bleed photo card -- the image fills the whole card, a dark
/// gradient fades in at the bottom so white text stays legible over
/// whatever the photo looks like, and the title/date sit directly on
/// that fade instead of a separate white content block underneath.
/// Standard promo-banner treatment (Play Store featured banners,
/// Netflix tiles): one photo, not "photo + label stuck below it".
///
/// No status pill -- every campaign this card is ever given is already
/// guaranteed active (get_active_campaigns() only returns those), so a
/// pill that always says the same word tells the viewer nothing.
class CampaignTile extends StatelessWidget {
  const CampaignTile({super.key, required this.campaign});

  final ActiveCampaign campaign;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      // push, not go: same fix as ProductTile -- go() replaces the
      // route with no back stack, which is why back from the detail
      // screen was landing on Home instead of returning to wherever
      // this card was tapped from (Home's carousel, or the full list).
      onTap: () => context.push('/campaigns/${campaign.id}'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              campaign.imageUrl != null
                  ? Image.network(
                      campaign.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _campaignImagePlaceholder(),
                    )
                  : _campaignImagePlaceholder(),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.35, 1],
                    colors: [Colors.transparent, Colors.black87],
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 10,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      campaign.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    if (campaign.dateWindow.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        campaign.dateWindow,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _campaignImagePlaceholder() {
    return Container(
      color: AppColors.primaryDark,
      child: const Center(
        child: Icon(Icons.campaign_outlined, size: 40, color: Colors.white38),
      ),
    );
  }
}

/// Home's campaign section. A single campaign shows as a plain full-width
/// CampaignTile, exactly as before -- carousel chrome (the peek viewport
/// and dots) only appears once there is something to browse between.
/// With 2+, cards peek in from the right edge (PageView with a
/// viewportFraction < 1) with dot indicators below, same pattern as most
/// apps' horizontally-scrolling offer rows.
class CampaignCarousel extends StatefulWidget {
  const CampaignCarousel({super.key, required this.campaigns});

  final List<ActiveCampaign> campaigns;

  @override
  State<CampaignCarousel> createState() => _CampaignCarouselState();
}

class _CampaignCarouselState extends State<CampaignCarousel> {
  late final _controller = PageController(viewportFraction: 0.86);
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.campaigns.isEmpty) return const SizedBox.shrink();

    if (widget.campaigns.length == 1) {
      return CampaignTile(campaign: widget.campaigns.single);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          // Matches CampaignTile's own 16:9 AspectRatio at roughly the
          // width a card renders at inside this carousel (viewportFraction
          // 0.86 minus the peek gutter) -- kept as a plain number here
          // since PageView needs one fixed height up front for every page.
          height: 176,
          child: PageView.builder(
            controller: _controller,
            // Without this, PageView adds invisible leading/trailing
            // padding so the FIRST and LAST card can also center in the
            // viewport -- which is exactly what was showing the previous
            // card peeking in from the left on the last page. false
            // keeps every card flush against the left edge, peeking only
            // on the right, matching the approved prototype.
            padEnds: false,
            itemCount: widget.campaigns.length,
            onPageChanged: (page) => setState(() => _page = page),
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: CampaignTile(campaign: widget.campaigns[index]),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < widget.campaigns.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _page ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == _page
                      ? AppColors.primary
                      : AppColors.outlineOf(context),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

String _formatDate(DateTime dateTime) {
  final local = dateTime.toLocal();
  final now = DateTime.now();
  final isToday =
      local.year == now.year &&
      local.month == now.month &&
      local.day == now.day;
  return isToday
      ? 'Today · ${DateFormat('h:mm a').format(local)}'
      : DateFormat('d MMM y').format(local);
}

class WithdrawalCard extends StatelessWidget {
  const WithdrawalCard({
    super.key,
    required this.withdrawal,
    required this.routePrefix,
  });

  final Withdrawal withdrawal;
  final String routePrefix;

  @override
  Widget build(BuildContext context) {
    final note = switch (withdrawal.status) {
      WithdrawalStatus.paymentSent =>
        'Please confirm after checking your balance.',
      WithdrawalStatus.disputed =>
        withdrawal.disputeReason ?? 'SGX is reviewing this payment problem.',
      WithdrawalStatus.confirmed ||
      WithdrawalStatus.autoConfirmed => 'Payment received and closed.',
      WithdrawalStatus.refunded => 'Refunded to your balance.',
      WithdrawalStatus.pending => 'Waiting for SGX to send payment.',
    };

    return Card(
      child: ListTile(
        onTap: () => context.push('$routePrefix/${withdrawal.id}'),
        leading: const CircleAvatar(child: Icon(Icons.payments_outlined)),
        title: Text(MoneyFormatter.format(withdrawal.amount)),
        subtitle: Text(
          '${withdrawal.method.label} · ${_formatDate(withdrawal.requestedAt)}\n$note',
        ),
        isThreeLine: true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _MiniPill(
              label: withdrawal.status.label,
              color: _statusColor(withdrawal.status),
            ),
            const Icon(Icons.chevron_right, size: 18),
          ],
        ),
      ),
    );
  }

  Color _statusColor(WithdrawalStatus status) {
    return switch (status) {
      WithdrawalStatus.confirmed ||
      WithdrawalStatus.autoConfirmed ||
      WithdrawalStatus.refunded => AppColors.success,
      WithdrawalStatus.disputed => AppColors.error,
      WithdrawalStatus.paymentSent => AppColors.primary,
      WithdrawalStatus.pending => AppColors.warning,
    };
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

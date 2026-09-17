import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/auth/auth_controller.dart';
import '../../models/app_role.dart';
import '../data/active_campaigns_providers.dart';
import '../domain/active_campaign.dart';
import 'widgets/campaign_detail_skeleton.dart';

/// Reached from a real CampaignTile tap, so this reads from the same
/// activeCampaignsProvider list Home already fetched -- no second
/// network call. A campaign that isn't in that list any more (expired,
/// or the link is just stale) gets an honest "not found" state instead
/// of silently substituting a different campaign's details, which is
/// what the old mock-data lookup used to do.
///
/// Deliberately doesn't use SgxScreen's standard AppBar -- an opaque
/// bar with a text title plus the campaign's own name on the photo
/// below it was showing the name twice. Here the name appears exactly
/// once (a small tag on the photo); the back button floats directly
/// over the hero instead, closer to how Acorns/ShopBack/Chime lay out
/// this exact kind of reward-detail page.
class CampaignDetailScreen extends ConsumerWidget {
  const CampaignDetailScreen({super.key, required this.campaignId});

  final String campaignId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaignsAsync = ref.watch(activeCampaignsProvider);

    ActiveCampaign? campaign;
    for (final item in campaignsAsync.value ?? const <ActiveCampaign>[]) {
      if (item.id == campaignId) {
        campaign = item;
        break;
      }
    }

    final topInset = MediaQuery.of(context).padding.top;

    // Hero photo runs edge-to-edge behind the status bar (see the
    // Stack below, no top SafeArea) instead of sitting under a plain
    // themed strip -- claims more of the page instead of reading
    // boxed-in. Always white icons, not following light/dark theme --
    // legibility against an arbitrary uploaded banner (which can be
    // anything, including a light one) is handled by _CampaignHero's
    // own fixed top gradient instead, not by switching icon color.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: PopScope(
        // Same fix as ProductDetailScreen: a top-level route reached
        // via context.go() (replace, not push) usually has no Flutter
        // route to pop, so an unhandled hardware/gesture back press
        // falls through to the OS and closes the app entirely instead
        // of navigating. Intercepting it here runs the exact same "go
        // back if possible, else go to my role's home" logic the
        // on-screen back button already uses.
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          _goBack(context, ref);
        },
        child: Scaffold(
          body: SafeArea(
            top: false,
            bottom: false,
            child: Stack(
              children: [
                campaignsAsync.when(
                  // Riverpod's default (true) shows the previous list
                  // while a refresh is in flight, to avoid flickering --
                  // right everywhere else, wrong here specifically: the
                  // notification tap that opens this screen is exactly
                  // what invalidated activeCampaignsProvider (see
                  // PushNotificationsCoordinator._refreshFor), because
                  // the campaign this screen wants isn't IN the old list
                  // yet. Showing that stale list during the refetch made
                  // a real campaign read as "no longer available" for
                  // the second or two the fresh fetch takes. false
                  // forces the skeleton for that window instead, so
                  // "not found" only ever means the fetch actually
                  // finished and the campaign genuinely isn't there.
                  skipLoadingOnRefresh: false,
                  data: (_) => campaign == null
                      ? const _CampaignNotFound()
                      : _CampaignDetailBody(campaign: campaign),
                  loading: () => const CampaignDetailSkeleton(),
                  error: (error, stackTrace) => const _CampaignNotFound(),
                ),
                Positioned(
                  top: topInset + 8,
                  left: 12,
                  child: _FloatingIconButton(
                    icon: Icons.arrow_back,
                    onTap: () => _goBack(context, ref),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _goBack(BuildContext context, WidgetRef ref) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    // Reached via CampaignTile's context.go(), which replaces the
    // route instead of pushing -- there's usually no back stack at
    // all here. This screen is shared by both roles, so the fallback
    // has to know who's actually signed in rather than always landing
    // a wholesaler on the mechanic home screen.
    final role = ref.read(authControllerProvider).profile?.role;
    context.go(
      role == AppRole.wholesaler ? '/wholesaler/home' : '/mechanic/home',
    );
  }
}

class _CampaignDetailBody extends StatelessWidget {
  const _CampaignDetailBody({required this.campaign});

  final ActiveCampaign campaign;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      children: [
        _CampaignHero(campaign: campaign),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (campaign.prizeNote != null) ...[
                _PrizeHighlight(prize: campaign.prizeNote!),
                const SizedBox(height: AppSpacing.md),
              ],
              _StatRow(campaign: campaign),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'About this campaign',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                (campaign.description?.trim().isNotEmpty ?? false)
                    ? campaign.description!.trim()
                    : 'No description added yet.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedTextOf(context),
                  height: 1.5,
                  fontStyle: (campaign.description?.trim().isNotEmpty ?? false)
                      ? FontStyle.normal
                      : FontStyle.italic,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'How to participate',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              const _StepLine(
                index: 1,
                text: 'Buy or install eligible SGX products.',
              ),
              const _StepLine(
                index: 2,
                text: 'Use the app normally during the campaign.',
              ),
              const _StepLine(
                index: 3,
                text: 'Rewards are credited when confirmed by SGX.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Taller than a card-in-a-row would need, rounded only at the bottom
/// (the top sits flush against the status bar/back button, like most
/// reward-detail heroes do) -- a small name tag floats on the photo
/// instead of a giant overlaid headline, since the name already
/// belongs to this whole page, not just the image.
class _CampaignHero extends StatelessWidget {
  const _CampaignHero({required this.campaign});

  final ActiveCampaign campaign;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      child: SizedBox(
        height: 300,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            campaign.imageUrl != null
                ? Image.network(
                    campaign.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _placeholder(),
                  )
                : _placeholder(),
            // Fixed dark strip behind the status bar, independent of
            // whatever the campaign banner actually looks like -- a
            // light-background banner would otherwise make the white
            // status bar icons unreadable, same issue found on
            // Product Detail with a white-background product photo.
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 80,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black38, Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 14,
              bottom: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  campaign.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.primaryDark,
      child: const Center(
        child: Icon(Icons.campaign_outlined, size: 56, color: Colors.white38),
      ),
    );
  }
}

class _FloatingIconButton extends StatelessWidget {
  const _FloatingIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.32),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(icon, size: 17, color: Colors.white),
        ),
      ),
    );
  }
}

/// The reason anyone opens this screen -- given the most visual
/// weight on the page instead of a small icon-plus-value row. Three
/// lines, same rhythm as the approved prototype: a small label saying
/// what this is, the value itself as big and bold as anything on the
/// page, then a plain-language line saying what happens with it --
/// the label alone ("Prize" + a bare number) doesn't say whether it's
/// cash, a product, or something you have to go collect.
class _PrizeHighlight extends StatelessWidget {
  const _PrizeHighlight({required this.prize});

  final String prize;

  /// prize_note is one free-text field staff can put anything in --
  /// a plain rupee amount ("100") or a non-cash prize ("Tool kit").
  /// Only prefix "Rs." when it's actually just a number; doing that
  /// unconditionally would put "Rs." in front of a product name too.
  static String _displayValue(String raw) {
    final trimmed = raw.trim();
    final parsed = num.tryParse(trimmed);
    if (parsed == null) return trimmed;
    return 'Rs. ${NumberFormat.decimalPattern().format(parsed)}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        children: [
          Text(
            'PRIZE',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.mutedTextOf(context),
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events, color: AppColors.gold, size: 36),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  _displayValue(prize),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 40,
                    color: AppColors.textOf(context),
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Credited to your wallet once SGX confirms you\'ve qualified.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.mutedTextOf(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.campaign});

  final ActiveCampaign campaign;

  @override
  Widget build(BuildContext context) {
    final endsLabel = _endsInLabel(campaign.endDate);
    final startedLabel = campaign.startDate != null
        ? DateFormat('d MMM').format(campaign.startDate!)
        : '—';

    return Row(
      children: [
        Expanded(
          child: _StatTile(
            label: 'Status',
            value: 'Active',
            valueColor: AppColors.success,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatTile(label: 'Ends', value: endsLabel),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatTile(label: 'Started', value: startedLabel),
        ),
      ],
    );
  }

  static String _endsInLabel(DateTime? endDate) {
    if (endDate == null) return '—';
    final today = DateTime.now();
    final daysLeft = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
    ).difference(DateTime(today.year, today.month, today.day)).inDays;
    if (daysLeft <= 0) return 'Last day';
    if (daysLeft == 1) return '1 day';
    return '$daysLeft days';
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineOf(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.mutedTextOf(context),
              fontWeight: FontWeight.w700,
              fontSize: 10.5,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: valueColor ?? AppColors.textOf(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _CampaignNotFound extends StatelessWidget {
  const _CampaignNotFound();

  @override
  Widget build(BuildContext context) {
    // Its own SafeArea(top) since the outer Stack deliberately isn't
    // safe-inset any more (the hero needs to run under the status
    // bar) -- this state has no hero to do that job for it.
    return SafeArea(
      top: true,
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          56,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: Column(
          children: [
            Icon(
              Icons.campaign_outlined,
              size: 40,
              color: AppColors.mutedTextOf(context),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'This campaign is no longer available.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedTextOf(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepLine extends StatelessWidget {
  const _StepLine({required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.primary,
            child: Text('$index', style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

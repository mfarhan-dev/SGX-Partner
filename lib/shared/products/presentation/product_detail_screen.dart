import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/auth/auth_controller.dart';
import '../../models/app_role.dart';
import '../data/catalog_products_providers.dart';
import '../domain/catalog_product.dart';

/// Real product detail via get_catalog_product() -- no price anywhere,
/// per instruction. Same treatment as CampaignDetailScreen (approved
/// "Option 1"): rounded-bottom hero, name shown exactly once as a tag
/// on the photo (not repeated as a big headline below), floating back
/// button over the hero instead of an opaque app bar. Products can
/// have several photos, so the hero is a swipeable gallery -- but the
/// page dots only appear once there's more than one photo to page
/// through; a single-photo product looks exactly like the campaign
/// screen's single-image case.
class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(catalogProductDetailProvider(productId));
    final topInset = MediaQuery.of(context).padding.top;

    // The hero photo runs edge-to-edge behind the status bar (see
    // Stack below, no top SafeArea) instead of sitting under a plain
    // cream strip -- reads more like a real photo screen and claims
    // more of the page instead of leaving it looking boxed-in. Always
    // white icons, not following light/dark theme -- legibility against
    // an arbitrary uploaded photo (which can be anything, including a
    // plain white product shot) is handled by _ProductHero's own fixed
    // top gradient instead, not by switching icon color.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: PopScope(
        // This screen is a top-level route, not a ShellRoute tab, and
        // is reached via context.go() (replace, not push) -- so there
        // is usually no Flutter route to pop at all. Left unhandled,
        // the hardware/gesture back button falls straight through to
        // the OS and closes the whole app instead of navigating
        // anywhere. Intercepting it here runs the exact same "go back
        // if possible, else go to my role's home" logic the on-screen
        // back button already uses, instead of the two ever disagreeing.
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
                productAsync.when(
                  data: (product) => product == null
                      ? const _ProductNotFound()
                      : _ProductDetailBody(product: product),
                  loading: () => Padding(
                    padding: EdgeInsets.only(top: topInset + 140),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stackTrace) => const _ProductNotFound(),
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
    // Reached via ProductTile's context.go(), which replaces the
    // route -- usually no back stack at all. Route to whichever role
    // is actually signed in, same fix as Campaign Detail and SgxAppBar.
    final role = ref.read(authControllerProvider).profile?.role;
    context.go(
      role == AppRole.wholesaler ? '/wholesaler/home' : '/mechanic/home',
    );
  }
}

class _ProductDetailBody extends StatelessWidget {
  const _ProductDetailBody({required this.product});

  final CatalogProductDetail product;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      children: [
        _ProductHero(product: product),
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: product.inStock
                      ? AppColors.successContainer
                      : AppColors.errorContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      product.inStock
                          ? Icons.check_circle
                          : Icons.cancel_outlined,
                      size: 16,
                      color: product.inStock
                          ? AppColors.success
                          : AppColors.error,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      product.inStock ? 'In stock' : 'Out of stock',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: product.inStock
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
              if (product.category != null || product.brand != null) ...[
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    if (product.category != null)
                      Expanded(
                        child: _InfoTile(
                          label: 'Category',
                          value: product.category!,
                        ),
                      ),
                    if (product.category != null && product.brand != null)
                      const SizedBox(width: AppSpacing.sm),
                    if (product.brand != null)
                      Expanded(
                        child: _InfoTile(label: 'Brand', value: product.brand!),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                (product.description?.trim().isNotEmpty ?? false)
                    ? product.description!.trim()
                    : 'No description added yet.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedTextOf(context),
                  height: 1.5,
                  fontStyle: (product.description?.trim().isNotEmpty ?? false)
                      ? FontStyle.normal
                      : FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A small labeled fact -- same shape as CampaignDetailScreen's
/// _StatTile, reused here for Category/Brand so a product with real
/// values fills the space with actual information instead of a single
/// thin eyebrow line.
class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

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
              color: AppColors.textOf(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// Rounded-bottom, swipeable gallery hero -- same shape as
/// CampaignDetailScreen's hero. The name tag is the ONLY place the
/// product name appears (no repeated headline below it), and the page
/// dots only render when there's actually more than one photo to page
/// through.
class _ProductHero extends StatefulWidget {
  const _ProductHero({required this.product});

  final CatalogProductDetail product;

  @override
  State<_ProductHero> createState() => _ProductHeroState();
}

class _ProductHeroState extends State<_ProductHero> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrls = widget.product.imageUrls;

    return Column(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(28),
          ),
          child: SizedBox(
            height: 300,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (imageUrls.isEmpty)
                  _placeholder(context)
                else
                  PageView.builder(
                    controller: _controller,
                    itemCount: imageUrls.length,
                    onPageChanged: (page) => setState(() => _page = page),
                    itemBuilder: (context, index) => Image.network(
                      imageUrls[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _placeholder(context),
                    ),
                  ),
                // Fixed dark strip behind the status bar, independent
                // of whatever the photo actually is -- a real product
                // photo is very often shot on a plain white background
                // (unlike the dark placeholder this was first tuned
                // against), and white status bar icons on a white photo
                // are basically invisible without this.
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
                      widget.product.name,
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
        ),
        if (imageUrls.length > 1) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < imageUrls.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: i == _page ? 16 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
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
      ],
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      color: AppColors.primaryDark,
      child: const Center(
        child: Icon(
          Icons.inventory_2_outlined,
          size: 56,
          color: Colors.white38,
        ),
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

class _ProductNotFound extends StatelessWidget {
  const _ProductNotFound();

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
              Icons.inventory_2_outlined,
              size: 40,
              color: AppColors.mutedTextOf(context),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'This product could not be found.',
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

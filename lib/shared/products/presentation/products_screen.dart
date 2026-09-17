import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../data/catalog_products_providers.dart';
import '../domain/catalog_product.dart';
import '../../widgets/sgx_cards.dart';
import 'widgets/products_grid_skeleton.dart';

/// Real catalog grid -- fetched once per session via
/// catalogProductsProvider, filtered client-side by search text and
/// category chip (both derived from the fetched list itself, not a
/// separate categories query: with only a handful of real products
/// today, a chip for a category that has zero products in it would
/// just look broken when tapped).
class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  String _query = '';
  String? _category;

  List<CatalogProduct> _filter(List<CatalogProduct> all) {
    final query = _query.trim().toLowerCase();
    return all.where((item) {
      final matchesCategory = _category == null || item.category == _category;
      final matchesQuery =
          query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          (item.brand?.toLowerCase().contains(query) ?? false) ||
          (item.category?.toLowerCase().contains(query) ?? false);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(catalogProductsProvider);

    // Same reasoning as the wholesaler ledger and QR Progress: the
    // catalog changes from the admin side, outside this app, and
    // catalogProductsProvider is deliberately session-cached -- without
    // this there was no way to see a new/updated product short of
    // restarting the app. Unlike balance/campaigns/withdrawals, a
    // catalog edit doesn't raise any user_notifications row (there's no
    // "this partner's product just changed" event to react to), so
    // pull-to-refresh is the right mechanism here, not a silent one.
    Future<void> refresh() async {
      ref.invalidate(catalogProductsProvider);
      await ref.read(catalogProductsProvider.future);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            tooltip: 'Search',
            onPressed: productsAsync.value == null
                ? null
                : () => _openSearch(productsAsync.value!),
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: refresh,
          child: productsAsync.when(
            data: (products) => _buildGrid(context, products),
            loading: () => const SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: ProductsGridSkeleton(),
            ),
            error: (error, stackTrace) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 96,
                ),
                child: Center(
                  child: Text(
                    'Could not load products. Pull to refresh or try again later.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.mutedTextOf(context)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<CatalogProduct> allProducts) {
    final categories = <String>{
      for (final item in allProducts)
        if (item.category != null) item.category!,
    }.toList()..sort();
    final filtered = _filter(allProducts);

    return ListView(
      // Explicit, not the default -- a short catalog (today's real
      // count is a handful of products) doesn't fill the viewport, and
      // without this a pull gesture has nothing to overscroll against,
      // so RefreshIndicator silently never triggers.
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        if (categories.isNotEmpty) ...[
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _CategoryChip(
                  label: 'All',
                  selected: _category == null,
                  onTap: () => setState(() => _category = null),
                ),
                for (final category in categories)
                  _CategoryChip(
                    label: category,
                    selected: _category == category,
                    onTap: () => setState(() => _category = category),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: Text(
                allProducts.isEmpty ? 'No products yet.' : 'No products found.',
                style: TextStyle(color: AppColors.mutedTextOf(context)),
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.66,
            ),
            itemBuilder: (context, index) =>
                ProductTile(product: filtered[index]),
          ),
      ],
    );
  }

  Future<void> _openSearch(List<CatalogProduct> products) async {
    final selectedQuery = await showSearch<String?>(
      context: context,
      delegate: _ProductSearchDelegate(
        initialQuery: _query,
        products: products,
      ),
      useRootNavigator: true,
    );

    if (!mounted || selectedQuery == null) {
      return;
    }

    setState(() => _query = selectedQuery);
  }
}

class _ProductSearchDelegate extends SearchDelegate<String?> {
  _ProductSearchDelegate({
    required String initialQuery,
    required this.products,
  }) {
    query = initialQuery;
  }

  final List<CatalogProduct> products;

  @override
  String get searchFieldLabel => 'Search products...';

  @override
  TextInputType? get keyboardType => TextInputType.text;

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: theme.inputDecorationTheme.copyWith(
        border: InputBorder.none,
        hintStyle: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    if (query.isEmpty) {
      return null;
    }

    return [
      IconButton(
        tooltip: 'Clear search',
        onPressed: () => query = '',
        icon: const Icon(Icons.close),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _ProductSearchResults(
      query: query,
      products: products,
      onSelected: (value) => close(context, value),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _ProductSearchResults(
      query: query,
      products: products,
      onSelected: (value) => close(context, value),
    );
  }
}

class _ProductSearchResults extends StatelessWidget {
  const _ProductSearchResults({
    required this.query,
    required this.products,
    required this.onSelected,
  });

  final String query;
  final List<CatalogProduct> products;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = query.trim().toLowerCase();
    final results = normalizedQuery.isEmpty
        ? products
        : products
              .where(
                (item) =>
                    item.name.toLowerCase().contains(normalizedQuery) ||
                    (item.brand?.toLowerCase().contains(normalizedQuery) ??
                        false) ||
                    (item.category?.toLowerCase().contains(normalizedQuery) ??
                        false),
              )
              .toList();
    final colorScheme = Theme.of(context).colorScheme;

    if (results.isEmpty) {
      return Center(
        child: Text(
          'No products found',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      );
    }

    return ListView.separated(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: results.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        indent: 72,
        color: colorScheme.outlineVariant.withValues(alpha: 0.6),
      ),
      itemBuilder: (context, index) {
        final product = results[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 6,
          ),
          leading: CircleAvatar(
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.onPrimaryContainer,
            backgroundImage: product.imageUrl != null
                ? NetworkImage(product.imageUrl!)
                : null,
            child: product.imageUrl == null
                ? const Icon(Icons.inventory_2_outlined)
                : null,
          ),
          title: Text(product.name),
          subtitle: Text(
            [
              product.brand,
              product.category,
            ].where((part) => part != null && part.isNotEmpty).join(' · '),
          ),
          onTap: () => onSelected(product.name),
        );
      },
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

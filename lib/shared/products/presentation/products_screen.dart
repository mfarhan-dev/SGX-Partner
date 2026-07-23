import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../mock/sgx_mock_data.dart';
import '../../widgets/sgx_cards.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final products = query.isEmpty
        ? mockProducts
        : mockProducts
              .where(
                (item) =>
                    item.name.toLowerCase().contains(query) ||
                    item.brand.toLowerCase().contains(query) ||
                    item.category.toLowerCase().contains(query) ||
                    item.code.toLowerCase().contains(query),
              )
              .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            tooltip: 'Search',
            onPressed: _openSearch,
            icon: const Icon(Icons.search),
          ),
          IconButton(
            tooltip: 'Filters',
            onPressed: _showFilters,
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  _CategoryChip(label: 'All', selected: true),
                  _CategoryChip(label: 'Engine Oil'),
                  _CategoryChip(label: 'Spark Plugs'),
                  _CategoryChip(label: 'Filters'),
                  _CategoryChip(label: 'Tires'),
                  _CategoryChip(label: 'Chains'),
                  _CategoryChip(label: 'Battery'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (context, index) =>
                  ProductTile(product: products[index]),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openSearch() async {
    final selectedQuery = await showSearch<String?>(
      context: context,
      delegate: _ProductSearchDelegate(initialQuery: _query),
      useRootNavigator: true,
    );

    if (!mounted || selectedQuery == null) {
      return;
    }

    setState(() => _query = selectedQuery);
  }

  void _showFilters() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter products',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  _CategoryChip(label: 'All', selected: true),
                  _CategoryChip(label: 'Engine Oil'),
                  _CategoryChip(label: 'Spark Plugs'),
                  _CategoryChip(label: 'Filters'),
                  _CategoryChip(label: 'Tires'),
                  _CategoryChip(label: 'Chains'),
                  _CategoryChip(label: 'Battery'),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.pop(),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProductSearchDelegate extends SearchDelegate<String?> {
  _ProductSearchDelegate({required String initialQuery}) {
    query = initialQuery;
  }

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
      onSelected: (value) => close(context, value),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _ProductSearchResults(
      query: query,
      onSelected: (value) => close(context, value),
    );
  }
}

class _ProductSearchResults extends StatelessWidget {
  const _ProductSearchResults({required this.query, required this.onSelected});

  final String query;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = query.trim().toLowerCase();
    final results = normalizedQuery.isEmpty
        ? mockProducts
        : mockProducts
              .where(
                (item) =>
                    item.name.toLowerCase().contains(normalizedQuery) ||
                    item.brand.toLowerCase().contains(normalizedQuery) ||
                    item.category.toLowerCase().contains(normalizedQuery) ||
                    item.code.toLowerCase().contains(normalizedQuery),
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
            child: Icon(product.icon),
          ),
          title: Text(product.name),
          subtitle: Text('${product.brand} · ${product.code}'),
          onTap: () => onSelected(product.name),
        );
      },
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {},
      ),
    );
  }
}

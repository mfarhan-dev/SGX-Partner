import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/catalog_product.dart';

/// Fetches the whole catalog once per session and caches it -- same
/// reasoning as mechanicProfileDataProvider/activeCampaignsProvider:
/// deliberately NOT .autoDispose, since Products is reached through a
/// plain ShellRoute that fully unmounts the previous tab's screen on
/// every switch (an autoDispose provider would refetch on every single
/// visit instead of caching for the session).
final catalogProductsProvider = FutureProvider<List<CatalogProduct>>((
  ref,
) async {
  final client = Supabase.instance.client;

  // get_catalog_products() already excludes every price column --
  // nothing to filter or hide client-side, it's just not in the row.
  final rows = await client.rpc('get_catalog_products') as List<dynamic>;

  return [
    for (final row in rows) _fromRow(client, row as Map<String, dynamic>),
  ];
});

CatalogProduct _fromRow(SupabaseClient client, Map<String, dynamic> row) {
  final imagePath = row['cover_image_path'] as String?;
  return CatalogProduct(
    id: row['id'] as String,
    name: row['name'] as String,
    stock: (row['stock'] as num?)?.toInt() ?? 0,
    category: row['category'] as String?,
    brand: row['brand'] as String?,
    // product-images is a public bucket -- a plain public URL, no
    // signed URL / expiry to worry about (unlike mechanic/wholesaler/
    // campaign photos, all of which are private buckets).
    imageUrl: imagePath != null
        ? client.storage.from('product-images').getPublicUrl(imagePath)
        : null,
  );
}

/// One product's full detail -- id-keyed so navigating between two
/// different products' detail pages never shows stale data, and
/// .autoDispose is fine here (unlike the list/profile providers)
/// since each id is its own cheap, independent fetch, not something
/// repeatedly re-shown on every tab switch.
final catalogProductDetailProvider = FutureProvider.autoDispose
    .family<CatalogProductDetail?, String>((ref, productId) async {
      final client = Supabase.instance.client;

      final rows =
          await client.rpc(
                'get_catalog_product',
                params: {'p_product_id': productId},
              )
              as List<dynamic>;
      if (rows.isEmpty) return null;

      final row = rows.first as Map<String, dynamic>;
      final paths = (row['image_paths'] as List<dynamic>?) ?? const [];

      return CatalogProductDetail(
        id: row['id'] as String,
        name: row['name'] as String,
        stock: (row['stock'] as num?)?.toInt() ?? 0,
        category: row['category'] as String?,
        brand: row['brand'] as String?,
        description: row['description'] as String?,
        imageUrls: [
          for (final path in paths)
            client.storage.from('product-images').getPublicUrl(path as String),
        ],
      );
    });

/// One row from get_catalog_products() -- deliberately carries no price
/// at all (not "the mechanic price" or "the wholesaler price", just
/// none), per instruction: prices are not shown for now.
class CatalogProduct {
  const CatalogProduct({
    required this.id,
    required this.name,
    required this.stock,
    this.category,
    this.brand,
    this.imageUrl,
  });

  final String id;
  final String name;
  final int stock;
  final String? category;
  final String? brand;

  /// Public URL into the product-images bucket (that bucket is public,
  /// unlike mechanic/wholesaler/campaign photos -- no signed URL, no
  /// per-viewer expiry).
  final String? imageUrl;

  bool get inStock => stock > 0;
}

/// get_catalog_product(id) -- the single-product detail fetch: same
/// core fields plus the description and every uploaded photo, not
/// just the cover. Kept separate from CatalogProduct (not a subclass)
/// since "one photo" vs. "every photo" are genuinely different shapes,
/// not an extension of the same one.
class CatalogProductDetail {
  const CatalogProductDetail({
    required this.id,
    required this.name,
    required this.stock,
    this.category,
    this.brand,
    this.description,
    this.imageUrls = const [],
  });

  final String id;
  final String name;
  final int stock;
  final String? category;
  final String? brand;
  final String? description;
  final List<String> imageUrls;

  bool get inStock => stock > 0;
}

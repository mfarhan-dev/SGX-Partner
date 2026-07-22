class ProductSummary {
  const ProductSummary({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    this.code,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String brand;
  final String category;
  final String? code;
  final String? imageUrl;
}

class ProductDetail extends ProductSummary {
  const ProductDetail({
    required super.id,
    required super.name,
    required super.brand,
    required super.category,
    required this.description,
    super.code,
    super.imageUrl,
  });

  final String description;
}

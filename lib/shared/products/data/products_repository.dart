import '../domain/product_models.dart';

abstract interface class ProductsRepository {
  Future<List<ProductSummary>> listProducts();

  Future<ProductDetail> getProduct(String productId);
}

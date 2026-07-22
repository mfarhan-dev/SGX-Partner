import '../../../shared/widgets/placeholder_screen.dart';

class ProductDetailScreen extends PlaceholderScreen {
  const ProductDetailScreen({super.key, required String productId})
    : super(
        title: 'Product Detail',
        description: 'Price-free product details for product ID: $productId.',
      );
}

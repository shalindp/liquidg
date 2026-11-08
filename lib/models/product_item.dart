import 'supermarket.dart';

class StorePrice {
  const StorePrice({
    required this.chain,
    required this.branch,
    required this.price,
  });

  final Supermarket chain;
  final String branch;
  final double? price;

  bool get available => price != null;

  String get label =>
      available ? '\$${price!.toStringAsFixed(2)}' : 'Not available';

  String? deltaFrom(double lowest) {
    final value = price;
    if (value == null || value <= lowest) return null;
    return '+\$${(value - lowest).toStringAsFixed(2)}';
  }
}

class ProductItem {
  const ProductItem({
    required this.id,
    required this.name,
    required this.packSize,
    required this.stores,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String packSize;
  final String? imageUrl;
  final List<StorePrice> stores;
}

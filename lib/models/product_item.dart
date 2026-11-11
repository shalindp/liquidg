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
    this.category = 'Other',
    this.imageUrl,
  });

  final String id;
  final String name;
  final String packSize;
  final String category;
  final String? imageUrl;
  final List<StorePrice> stores;
}

class PriceRange {
  const PriceRange(this.low, this.high);

  final double low;
  final double high;

  bool get isSingle => (high - low).abs() < 0.005;

  PriceRange times(int count) => PriceRange(low * count, high * count);

  PriceRange operator +(PriceRange other) =>
      PriceRange(low + other.low, high + other.high);

  String get label => isSingle
      ? '\$${low.toStringAsFixed(2)}'
      : '\$${low.toStringAsFixed(2)} - \$${high.toStringAsFixed(2)}';
}

extension ProductItemPricing on ProductItem {
  PriceRange get priceRange {
    final prices = [
      for (final store in stores)
        if (store.price != null) store.price!,
    ];
    if (prices.isEmpty) return const PriceRange(0, 0);
    prices.sort();
    return PriceRange(prices.first, prices.last);
  }
}

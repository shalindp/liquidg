import 'package:signals_flutter/signals_flutter.dart';

import '../../models/product_item.dart';
import '../../services/products_screen_service.dart';

class ProductPrice {
  const ProductPrice({required this.dollars, required this.cents});

  factory ProductPrice.of(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    return ProductPrice(dollars: parts[0], cents: parts[1]);
  }

  final String dollars;
  final String cents;
}

class ProductCardController {
  ProductCardController(this.item, this._basket)
    : lowestStore = item.stores.first,
      stores = item.stores.skip(1).toList(growable: false);

  static const int collapsedLimit = 3;
  static const int expandedLimit = 6;

  final ProductItem item;
  final ProductsScreenService _basket;
  final StorePrice lowestStore;
  final List<StorePrice> stores;

  String get name => '${item.name} ${item.packSize}';
  String? get imageUrl => item.imageUrl;
  late final String unitPrice =
      '\$${(lowest / 10).toStringAsFixed(2)} per 100g';
  late final double lowest = lowestStore.price!;
  late final lowestPrice = ProductPrice.of(lowest);

  late final quantity = computed(() => _basket.quantityOf(item.id));
  late final hasQuantity = computed(() => quantity.value > 0);

  final favourite = signal(false);
  final storesExpanded = signal(false);

  late final visibleLimit = computed(
    () => storesExpanded.value ? expandedLimit : collapsedLimit,
  );
  late final visibleCount = computed(
    () =>
        stores.length < visibleLimit.value ? stores.length : visibleLimit.value,
  );

  bool get canExpand => stores.length > collapsedLimit;

  void setQuantity(int value) => _basket.setQuantity(item, value);

  void toggleFavourite() => favourite.value = !favourite.value;

  void toggleStores() => storesExpanded.value = !storesExpanded.value;

  void dispose() {
    quantity.dispose();
    hasQuantity.dispose();
    favourite.dispose();
    storesExpanded.dispose();
    visibleLimit.dispose();
    visibleCount.dispose();
  }
}

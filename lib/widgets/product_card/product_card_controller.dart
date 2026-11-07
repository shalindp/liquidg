import 'package:signals_flutter/signals_flutter.dart';

class StorePrice {
  const StorePrice({required this.name, required this.price});

  final String name;
  final String price;
}

class ProductCardController {
  static const int collapsedLimit = 3;
  static const int expandedLimit = 6;

  final name = 'Anchor Lite Milk 2L';
  final imageUrl =
      'https://assets.woolworths.com.au/images/2010/282819.jpg?impolicy=wowb2bgpkhx';
  final lowestPrice = '\$4.52';
  final unitPrice = '(\$2.26/L)';
  final stores = const <StorePrice>[
    StorePrice(name: 'Woolworths Northlands', price: '\$5.23'),
    StorePrice(name: 'Woolworths Alexandra', price: '\$5.23'),
    StorePrice(name: 'Woolworths Preston', price: '\$5.29'),
    StorePrice(name: 'Woolworths Reservoir', price: '\$5.35'),
    StorePrice(name: 'Woolworths Thornbury', price: '\$5.40'),
    StorePrice(name: 'Woolworths Coburg', price: '\$5.45'),
    StorePrice(name: 'Woolworths Brunswick', price: '\$5.50'),
    StorePrice(name: 'Woolworths Fitzroy', price: '\$5.60'),
  ];

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

  void toggleFavourite() => favourite.value = !favourite.value;

  void toggleStores() => storesExpanded.value = !storesExpanded.value;

  void dispose() {
    favourite.dispose();
    storesExpanded.dispose();
    visibleLimit.dispose();
    visibleCount.dispose();
  }
}

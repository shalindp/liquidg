import 'package:signals_flutter/signals_flutter.dart';

class StorePrice {
  const StorePrice({
    required this.chain,
    required this.branch,
    required this.price,
  });

  final String chain;
  final String branch;
  final double price;

  String get name => '$chain $branch';

  String get label => '\$${price.toStringAsFixed(2)}';

  String deltaFrom(double lowest) =>
      '+\$${(price - lowest).toStringAsFixed(2)}';
}

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
  static const int collapsedLimit = 3;
  static const int expandedLimit = 6;

  final name = 'Anchor Lite Milk 2L';
  final imageUrl =
      'https://assets.woolworths.com.au/images/2010/282819.jpg?impolicy=wowb2bgpkhx';
  final lowestStore = const StorePrice(
    chain: 'Woolworths',
    branch: 'Northlands',
    price: 16.79,
  );
  late final lowestPrice = ProductPrice.of(lowestStore.price);
  final unitPrice = '(\$8.40/L)';
  final stores = const <StorePrice>[
    StorePrice(chain: 'Woolworths', branch: 'Alexandra', price: 17.20),
    StorePrice(chain: 'Woolworths', branch: 'Preston', price: 17.45),
    StorePrice(chain: 'Woolworths', branch: 'Reservoir', price: 17.90),
    StorePrice(chain: 'Woolworths', branch: 'Thornbury', price: 18.10),
    StorePrice(chain: 'Woolworths', branch: 'Coburg', price: 18.35),
    StorePrice(chain: 'Woolworths', branch: 'Brunswick', price: 18.80),
    StorePrice(chain: 'Woolworths', branch: 'Fitzroy', price: 19.40),
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

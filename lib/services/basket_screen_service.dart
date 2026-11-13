import 'package:signals_flutter/signals_flutter.dart';

import '../models/product_item.dart';
import '../query/query.dart';
import 'basket_sync_service.dart';

import 'package:ominicart_api/ominicart_api.dart';

import 'products_screen_service.dart';
import 'query_service.dart';
import 'stores_service.dart';

class BasketLine {
  const BasketLine({required this.item, required this.quantity});

  final ProductItem item;
  final int quantity;

  PriceRange get total => item.priceRange.times(quantity);
}

class BasketGroup {
  const BasketGroup({required this.category, required this.lines});

  final String category;
  final List<BasketLine> lines;
}

class BasketScreenService {
  BasketScreenService(this._products, this._stores, this._sync, this._queries);

  static const int minQuantity = 1;

  final ProductsScreenService _products;
  final StoresService _stores;
  final BasketSyncService _sync;
  final QueryService _queries;

  late final Mutation<ShoppingList?, ({String name, List<int> storeIds})>
  _createList = _queries
      .useCreateListFromBasket();

  final creating = signal(false);

  late final lines = computed(() {
    final quantities = _products.quantities.value;
    final items = _products.basketItems.value;
    return [
      for (final entry in items.entries)
        if ((quantities[entry.key] ?? 0) > 0)
          BasketLine(item: entry.value, quantity: quantities[entry.key]!),
    ];
  });

  late final groups = computed(() {
    final byCategory = <String, List<BasketLine>>{};
    for (final line in lines.value) {
      byCategory.putIfAbsent(line.item.category, () => []).add(line);
    }
    final categories = byCategory.keys.toList()..sort();
    return [
      for (final category in categories)
        BasketGroup(category: category, lines: byCategory[category]!),
    ];
  });

  late final itemCount = computed(() => _products.totalCount.value);

  late final total = computed(
    () => lines.value.fold(
      const PriceRange(0, 0),
      (sum, line) => sum + line.total,
    ),
  );

  late final savings = computed(() => total.value.high - total.value.low);

  late final storeCount = computed(() => _stores.selectedIds.value.length);

  void setQuantity(BasketLine line, int quantity) {
    _products.setQuantity(line.item, quantity);
  }

  void increment(BasketLine line) => setQuantity(line, line.quantity + 1);

  void decrement(BasketLine line) {
    if (line.quantity > minQuantity) setQuantity(line, line.quantity - 1);
  }

  void remove(BasketLine line) => setQuantity(line, 0);

  void clear() => _products.clearBasket();

  Future<bool> createList(String name) async {
    if (creating.value) return false;
    creating.value = true;
    try {
      await _sync.flush();
      final created = await _createList.mutate((
        name: name.trim(),
        storeIds: _stores.selectedIds.value,
      ));
      if (created == null) return false;
      _sync.discardPending();
      _products.resetBasketLocally();
      return true;
    } finally {
      creating.value = false;
    }
  }

  void dispose() {
    lines.dispose();
    groups.dispose();
    itemCount.dispose();
    total.dispose();
    savings.dispose();
    storeCount.dispose();
    creating.dispose();
    _createList.dispose();
  }
}

import 'dart:async';

import 'package:signals_flutter/signals_flutter.dart';

import 'query_service.dart';

class FavouritesService {
  FavouritesService(this._queries);

  static const Duration pushDelay = Duration(milliseconds: 500);
  static const int pageSize = 100;

  final QueryService _queries;

  late final _set = _queries.useSetFavourites();

  final ids = signal<Set<String>>(const {});

  Timer? _timer;
  bool _pushing = false;
  bool _dirty = false;
  bool _disposed = false;

  ReadonlySignal<bool> watch(String productId) =>
      computed(() => ids.value.contains(productId));

  Future<void> load() async {
    final loaded = <String>{};
    var skip = 0;
    while (true) {
      final query = _queries.useGetProducts(
        searchTerm: '',
        showFavourites: true,
        skip: skip,
        limit: pageSize,
        storeIds: const [],
      );
      try {
        final page = await query.trigger(force: true);
        if (page == null) return;
        for (final product in page.products) {
          loaded.add(product.productId);
        }
        skip = page.skip + page.products.length;
        if (page.products.isEmpty || skip >= page.total) break;
      } finally {
        query.dispose();
      }
    }
    if (_disposed) return;
    ids.value = {...loaded, ...ids.value};
  }

  void toggle(String productId) {
    final next = {...ids.value};
    if (!next.remove(productId)) next.add(productId);
    ids.value = next;
    _dirty = true;
    _timer?.cancel();
    _timer = Timer(pushDelay, _flush);
  }

  Future<void> _flush() async {
    if (_disposed || _pushing || !_dirty) return;
    _dirty = false;
    _pushing = true;
    try {
      await _set.mutate(ids.value.toList());
    } finally {
      _pushing = false;
      if (_dirty && !_disposed) {
        _timer?.cancel();
        _timer = Timer(pushDelay, _flush);
      }
    }
  }

  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _set.dispose();
    ids.dispose();
  }
}

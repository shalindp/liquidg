import 'dart:async';

import 'package:ominicart_api/ominicart_api.dart';

import '../query/query.dart';
import 'query_service.dart';

class BasketSyncService {
  BasketSyncService(this._queries);

  static const Duration pushDelay = Duration(milliseconds: 400);

  final QueryService _queries;

  late final Mutation<Basket?, List<ProductQuantityRequest>> _set = _queries
      .useSetBasket();

  Timer? _timer;
  Map<String, int>? _pending;
  bool _pushing = false;
  bool _disposed = false;

  Future<List<BasketItem>> fetch() async {
    final query = _queries.useGetBasket();
    try {
      final basket = await query.trigger(force: true);
      return basket?.items ?? const [];
    } finally {
      query.dispose();
    }
  }

  void schedulePush(Map<String, int> quantities) {
    _pending = quantities;
    _timer?.cancel();
    _timer = Timer(pushDelay, _flush);
  }

  Future<void> flush() async {
    _timer?.cancel();
    while (_pushing) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    await _flush();
  }

  void discardPending() {
    _timer?.cancel();
    _pending = null;
  }

  Future<void> _flush() async {
    if (_disposed || _pushing) return;
    final snapshot = _pending;
    if (snapshot == null) return;
    _pending = null;
    _pushing = true;
    try {
      await _set.mutate([
        for (final entry in snapshot.entries)
          if (entry.value > 0)
            ProductQuantityRequest(productId: entry.key, quantity: entry.value),
      ]);
    } finally {
      _pushing = false;
      if (_pending != null && !_disposed) {
        _timer?.cancel();
        _timer = Timer(pushDelay, _flush);
      }
    }
  }

  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _set.dispose();
  }
}

import 'package:ominicart_api/ominicart_api.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../query/query.dart';
import 'query_service.dart';

class ProductsScreenService {
  ProductsScreenService(this._queries);

  static const int pageSize = 20;

  final QueryService _queries;

  final searchTerm = signal('');
  final storeIds = signal<List<int>>(const []);
  final _current = signal<LazyQuery<ProductsResponse?>?>(null);

  late final products = computed(
    () => _current.value?.$data.value?.products ?? const <ProductSummary>[],
  );
  late final loading = computed(() => _current.value?.$loading.value ?? false);
  late final error = computed(() => _current.value?.$error.value);

  Future<void> load({bool force = false}) async {
    final previous = _current.value;
    final next = _queries.useGetProducts(
      searchTerm: searchTerm.value,
      skip: 0,
      limit: pageSize,
      storeIds: storeIds.value,
    );
    _current.value = next;
    previous?.dispose();
    await next.trigger(force: force);
  }

  Future<void> search(String term) {
    searchTerm.value = term;
    return load();
  }

  Future<void> setStores(List<int> ids) {
    storeIds.value = ids;
    return load();
  }

  Future<void> refresh() => load(force: true);

  void dispose() => _current.value?.dispose();
}

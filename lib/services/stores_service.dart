import 'package:latlong2/latlong.dart';
import 'package:ominicart_api/ominicart_api.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../models/store_location.dart';
import '../models/supermarket.dart';
import '../query/query.dart';
import 'query_service.dart';

class StoresService {
  StoresService(this._queries);

  static const defaultStoreIds = <int>[159, 158, 160, 208, 203, 291, 264];

  final QueryService _queries;

  late final LazyQuery<List<Store>> _storesQuery = _queries.useGetStores();
  late final Mutation<SetUserStoresResponse?, List<int>> _setStores = _queries
      .useSetUserStores();

  final selectedIds = signal<List<int>>(defaultStoreIds);
  final appliedIds = signal<List<int>>(defaultStoreIds);

  int _generation = 0;

  late final stores = computed(
    () => _toLocations(_storesQuery.$data.value ?? const []),
  );

  late final selected = computed(() {
    final byId = {for (final store in stores.value) store.id: store};
    return [for (final id in selectedIds.value) ?byId[id]];
  });

  late final applied = computed(() => _resolve(appliedIds.value));

  Signal<Object?> get error => _storesQuery.$error;

  Future<bool> ensureLoaded({bool force = false}) async {
    if (stores.value.isNotEmpty && !force) return true;
    final result = await _storesQuery.trigger(force: force);
    return result != null && result.isNotEmpty;
  }

  Future<void> select(List<int> ids) async {
    final generation = ++_generation;
    selectedIds.value = ids;
    await _setStores.mutate(ids);
    if (generation == _generation) appliedIds.value = ids;
  }

  List<StoreLocation> _resolve(List<int> ids) {
    final byId = {for (final store in stores.value) store.id: store};
    return [for (final id in ids) ?byId[id]];
  }

  Future<void> reset() => select(defaultStoreIds);

  List<StoreLocation> _toLocations(List<Store> supermarkets) {
    return [
      for (final supermarket in supermarkets)
        if (Supermarket.fromApiName(supermarket.name) case final chain?)
          for (final branch in supermarket.regions)
            StoreLocation(
              id: branch.storeId,
              supermarket: chain,
              name: branch.name,
              position: LatLng(branch.latitude, branch.longitude),
            ),
    ];
  }

  void dispose() {
    stores.dispose();
    selected.dispose();
    applied.dispose();
    appliedIds.dispose();
    selectedIds.dispose();
    _storesQuery.dispose();
    _setStores.dispose();
  }
}

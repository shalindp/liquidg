import 'package:latlong2/latlong.dart';
import 'package:ominicart_api/ominicart_api.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../models/store_location.dart';
import '../models/supermarket.dart';
import '../query/query.dart';
import 'query_service.dart';

class StoresService {
  StoresService(this._queries, this._defaultStoreIds);

  final QueryService _queries;
  final List<int> _defaultStoreIds;

  late final LazyQuery<List<Store>> _storesQuery = _queries.useGetStores();
  late final LazyQuery<List<Store>> _selectedQuery = _queries
      .useGetSelectedStores();
  late final Mutation<SetUserStoresResponse?, List<int>> _setStores = _queries
      .useSetUserStores();

  final selectedIds = signal<List<int>>(const []);
  final appliedIds = signal<List<int>>(const []);
  final ready = signal(false);
  final saving = signal(false);

  int _generation = 0;
  int _inflight = 0;

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
    if (stores.value.isNotEmpty && ready.value && !force) return true;
    final results = await Future.wait([
      _storesQuery.trigger(force: force),
      if (!ready.value || force) _loadSelection(),
    ]);
    final loaded = results.first;
    return loaded != null && loaded.isNotEmpty;
  }

  Future<List<Store>?> _loadSelection() async {
    final generation = _generation;
    final result = await _selectedQuery.trigger(force: true);
    if (generation == _generation) {
      final ids = [
        for (final supermarket in result ?? const <Store>[])
          for (final branch in supermarket.regions) branch.storeId,
      ];
      final resolved = ids.isEmpty ? _defaultStoreIds : ids;
      selectedIds.value = resolved;
      appliedIds.value = resolved;
    }
    ready.value = true;
    return result;
  }

  Future<void> select(List<int> ids, {bool optimistic = true}) async {
    final generation = ++_generation;
    if (optimistic) selectedIds.value = ids;
    _inflight++;
    saving.value = true;
    try {
      await _setStores.mutate(ids);
      if (generation == _generation) {
        selectedIds.value = ids;
        appliedIds.value = ids;
      }
    } finally {
      _inflight--;
      saving.value = _inflight > 0;
    }
  }

  List<StoreLocation> _resolve(List<int> ids) {
    final byId = {for (final store in stores.value) store.id: store};
    return [for (final id in ids) ?byId[id]];
  }

  Future<void> reset() => select(_defaultStoreIds);

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
    ready.dispose();
    saving.dispose();
    selectedIds.dispose();
    _storesQuery.dispose();
    _selectedQuery.dispose();
    _setStores.dispose();
  }
}

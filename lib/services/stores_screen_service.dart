import 'dart:async';

import 'package:latlong2/latlong.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../models/store_location.dart';
import '../models/supermarket.dart';
import '../utils/geo_util.dart';
import 'location_service.dart';
import 'stores_service.dart';

enum StoresMapStatus {
  loading,
  ready,
  permissionDenied,
  servicesDisabled,
  unavailable,
}

typedef StoreDistance = ({StoreLocation store, double kilometres});

class StoresScreenService {
  StoresScreenService(this._stores, this._location);

  static const Duration searchDebounce = Duration(milliseconds: 350);
  static const Duration messageDuration = Duration(seconds: 3);
  static const String minimumStoreMessage =
      'Keep at least one store picked so we can hunt down the best prices for you.';

  final StoresService _stores;
  final LocationService _location;

  final status = signal(StoresMapStatus.loading);
  final userLocation = signal<LatLng?>(null);
  final filters = signal<Set<Supermarket>>(const {});
  final trayExpanded = signal(false);
  final query = signal('');
  final message = signal<String?>(null);
  final searchFocused = signal(false);

  late final distances = computed(() {
    final location = userLocation.value;
    if (location == null) return const <StoreDistance>[];
    return [
      for (final store in _stores.stores.value)
        (
          store: store,
          kilometres: GeoUtil.kilometres(location, store.position),
        ),
    ];
  });

  late final visible = computed(() {
    final active = filters.value;
    if (active.isEmpty) return distances.value;
    return [
      for (final entry in distances.value)
        if (active.contains(entry.store.supermarket)) entry,
    ];
  });

  late final selectedIds = computed(
    () => {for (final store in _stores.selected.value) store.id},
  );

  late final selectedEntries = computed(() {
    final byId = {for (final entry in distances.value) entry.store.id: entry};
    return [for (final store in _stores.selected.value) ?byId[store.id]];
  });

  late final results = computed(() {
    final term = query.value.trim().toLowerCase();
    if (term.isEmpty) return const <StoreDistance>[];
    final matches = [
      for (final entry in visible.value)
        if (entry.store.name.toLowerCase().contains(term) ||
            entry.store.supermarket.label.toLowerCase().contains(term))
          entry,
    ];
    matches.sort((a, b) => a.kilometres.compareTo(b.kilometres));
    return matches;
  });

  Timer? _searchTimer;
  Timer? _messageTimer;
  bool _busy = false;
  bool _disposed = false;

  Future<void> load() async {
    if (status.value != StoresMapStatus.ready) {
      status.value = StoresMapStatus.loading;
    }
    await Future.wait([_fetchLocation(), _stores.ensureLoaded()]);
  }

  Future<void> retry() async {
    status.value = StoresMapStatus.loading;
    await Future.wait([_fetchLocation(), _stores.ensureLoaded(force: true)]);
  }

  Future<LatLng?> recenter() => _fetchLocation();

  void onSearchChanged(String term) {
    _searchTimer?.cancel();
    _searchTimer = Timer(searchDebounce, () => setQuery(term));
  }

  void setQuery(String term) {
    if (_disposed) return;
    query.value = term;
  }

  void toggleStore(StoreLocation store) {
    if (_disposed) return;
    final current = _stores.selectedIds.value;
    if (current.contains(store.id)) {
      if (current.length == 1) {
        _showMessage(minimumStoreMessage);
        return;
      }
      _stores.select([
        for (final id in current)
          if (id != store.id) id,
      ]);
    } else {
      _stores.select([...current, store.id]);
    }
    if (_stores.selectedIds.value.length <= 1) trayExpanded.value = false;
  }

  Future<void> resetSelected() async {
    trayExpanded.value = false;
    await _stores.reset();
  }

  void toggleTray() {
    if (_disposed || selectedEntries.value.isEmpty) return;
    trayExpanded.value = !trayExpanded.value;
  }

  void toggleFilter(Supermarket supermarket) {
    if (_disposed) return;
    final current = filters.value;
    filters.value = current.contains(supermarket)
        ? {...current}.difference({supermarket})
        : {...current, supermarket};
  }

  void clearFilters() {
    if (_disposed) return;
    filters.value = const {};
  }

  void _showMessage(String text) {
    message.value = text;
    _messageTimer?.cancel();
    _messageTimer = Timer(messageDuration, () {
      if (!_disposed) message.value = null;
    });
  }

  Future<LatLng?> _fetchLocation() async {
    if (_busy) return null;
    _busy = true;
    try {
      if (userLocation.value == null) {
        final cached = await _location.cachedPosition();
        if (cached != null) _show(cached);
      }
      final location = await _location.currentPosition();
      if (_disposed) return null;
      _show(location);
      return location;
    } on LocationException catch (error) {
      if (!_disposed) {
        status.value = switch (error.failure) {
          LocationFailure.permissionDenied => StoresMapStatus.permissionDenied,
          LocationFailure.servicesDisabled => StoresMapStatus.servicesDisabled,
          LocationFailure.unavailable => StoresMapStatus.unavailable,
        };
      }
      return null;
    } finally {
      _busy = false;
    }
  }

  void _show(LatLng location) {
    if (_disposed) return;
    userLocation.value = location;
    status.value = StoresMapStatus.ready;
  }

  void dispose() {
    _disposed = true;
    _searchTimer?.cancel();
    _messageTimer?.cancel();
    distances.dispose();
    visible.dispose();
    selectedIds.dispose();
    selectedEntries.dispose();
    results.dispose();
    status.dispose();
    userLocation.dispose();
    filters.dispose();
    trayExpanded.dispose();
    query.dispose();
    message.dispose();
    searchFocused.dispose();
  }
}

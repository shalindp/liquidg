import 'dart:async';

import 'package:latlong2/latlong.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../models/store_location.dart';
import '../models/supermarket.dart';
import '../utils/geo_util.dart';
import 'device_permission_service.dart';
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
  StoresScreenService(this._stores, this._location, this._permissions) {
    _disposePermission = _permissions.statuses.subscribe((_) {
      final granted = _permissions
          .statusOf(DevicePermission.location)
          .isGranted;
      if (granted &&
          !_wasGranted &&
          status.value == StoresMapStatus.permissionDenied) {
        retry();
      }
      _wasGranted = granted;
    });
  }

  static const Duration searchDebounce = Duration(milliseconds: 350);
  static const double minRadiusKm = 1;
  static const double maxRadiusKm = 30;
  static const Duration messageDuration = Duration(seconds: 3);
  static const String minimumStoreMessage =
      'Keep at least one store picked so we can hunt down the best prices for you.';

  final StoresService _stores;
  final LocationService _location;
  final DevicePermissionService _permissions;
  late final void Function() _disposePermission;
  bool _wasGranted = false;

  final status = signal(StoresMapStatus.loading);
  final userLocation = signal<LatLng?>(null);
  final filters = signal<Set<Supermarket>>(const {});
  final radiusKm = signal<double?>(null);
  final trayExpanded = signal(false);
  final focusedId = signal<int?>(null);
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
    final radius = radiusKm.value;
    return [
      for (final entry in distances.value)
        if ((active.isEmpty || active.contains(entry.store.supermarket)) &&
            (radius == null || entry.kilometres <= radius))
          entry,
    ];
  });

  late final chainCounts = computed(() {
    final radius = radiusKm.value;
    final counts = {for (final chain in Supermarket.values) chain: 0};
    for (final entry in distances.value) {
      if (radius == null || entry.kilometres <= radius) {
        counts[entry.store.supermarket] = counts[entry.store.supermarket]! + 1;
      }
    }
    return counts;
  });

  late final activeFilterCount = computed(
    () => filters.value.length + (radiusKm.value == null ? 0 : 1),
  );

  late final focused = computed(() {
    final id = focusedId.value;
    if (id == null) return null;
    for (final entry in visible.value) {
      if (entry.store.id == id) return entry;
    }
    return null;
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

  void focusStore(StoreLocation store) {
    if (_disposed) return;
    focusedId.value = focusedId.value == store.id ? null : store.id;
  }

  void toggleFromCallout(StoreLocation store) {
    toggleStore(store);
    clearFocus();
  }

  void clearFocus() {
    if (_disposed) return;
    if (focusedId.value != null) focusedId.value = null;
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

  void setRadius(double? km) {
    if (_disposed) return;
    radiusKm.value = km == null || km >= maxRadiusKm ? null : km;
  }

  void resetFilters() {
    if (_disposed) return;
    filters.value = const {};
    radiusKm.value = null;
  }

  void setAllSupermarkets({required bool on}) {
    if (_disposed) return;
    filters.value = on ? const {} : {...Supermarket.values};
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
    _disposePermission();
    _searchTimer?.cancel();
    _messageTimer?.cancel();
    distances.dispose();
    visible.dispose();
    focused.dispose();
    focusedId.dispose();
    chainCounts.dispose();
    activeFilterCount.dispose();
    radiusKm.dispose();
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

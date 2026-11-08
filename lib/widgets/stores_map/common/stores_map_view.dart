part of '../stores_map.dart';

class _StoresMapView extends StatelessWidget {
  const _StoresMapView({
    required this.service,
    required this.mapController,
    required this.contentTop,
    required this.onRecenter,
  });

  static const double _initialRadiusMeters = 2250;
  static const double _minZoom = 5;
  static const double _maxZoom = 16;
  static const int _maxNativeZoom = 16;
  static const double _nzSouth = -47.6;
  static const double _nzWest = 165.8;
  static const double _nzNorth = -33.9;
  static const double _nzEast = 179.0;
  static final LatLngBounds _nzBounds = LatLngBounds(
    const LatLng(_nzSouth, _nzWest),
    const LatLng(_nzNorth, _nzEast),
  );
  static const String _tilePrefix =
      'https://server.arcgisonline.com/ArcGIS/rest/services/Canvas/';
  static const String _tileSuffix = '/MapServer/tile/{z}/{y}/{x}';
  static const String _darkTiles =
      '${_tilePrefix}World_Dark_Gray_Base$_tileSuffix';
  static const String _lightTiles =
      '${_tilePrefix}World_Light_Gray_Base$_tileSuffix';
  static const String _userAgentPackage = 'com.example.uxapp';

  static LatLngBounds _initialBounds(
    LatLng location,
    List<StoreDistance> visible,
  ) {
    if (_nzBounds.contains(location)) {
      return GeoUtil.boundsAround(location, _initialRadiusMeters);
    }
    if (visible.isEmpty) return _nzBounds;
    return LatLngBounds.fromPoints([
      for (final entry in visible) entry.store.position,
    ]);
  }

  final StoresScreenService service;
  final MapController mapController;
  final double contentTop;
  final VoidCallback onRecenter;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.brightnessOf(context) == Brightness.dark;
    final clearance = NavMetrics.clearanceOf(context);
    final screenHeight = MediaQuery.sizeOf(context).height;

    return SignalBuilder(
      builder: (context) {
        final location = service.userLocation.value;
        if (location == null) {
          return const Center(
            child: CircularProgressIndicator(color: BrandColors.accent500),
          );
        }
        final visible = service.visible.value;
        final selectedIds = service.selectedIds.value;
        final entries = service.selectedEntries.value;
        final searching =
            service.query.value.trim().isNotEmpty &&
            service.searchFocused.value;
        final trayExpanded = service.trayExpanded.value && !searching;
        final message = service.message.value;
        final resultsTop = contentTop;

        return LayoutBuilder(
          builder: (context, constraints) {
            final keyboardOpen = constraints.maxHeight < screenHeight;
            final bottom = keyboardOpen ? TwSpacing.s3 : clearance;
            return Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialRotation: 0,
                    initialCameraFit: CameraFit.bounds(
                      bounds: _initialBounds(location, visible),
                      padding: const EdgeInsets.all(TwSpacing.s8),
                    ),
                    minZoom: _minZoom,
                    maxZoom: _maxZoom,
                    cameraConstraint: CameraConstraint.contain(
                      bounds: _nzBounds,
                    ),
                    backgroundColor: isDark
                        ? TwColors.zinc.s700
                        : TwColors.zinc.s100,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: isDark ? _darkTiles : _lightTiles,
                      userAgentPackageName: _userAgentPackage,
                      maxNativeZoom: _maxNativeZoom,
                      retinaMode: RetinaMode.isHighDensity(context),
                    ),
                    MarkerLayer(
                      markers: [
                        for (final entry in visible)
                          Marker(
                            key: ValueKey('badge-${entry.store.id}'),
                            point: entry.store.position,
                            width: _StoreMarkerBadge.width,
                            height: _StoreMarkerBadge.height,
                            alignment: Alignment.topCenter,
                            rotate: true,
                            child: _StoreMarkerBadge(
                              store: entry.store,
                              selected: selectedIds.contains(entry.store.id),
                              onTap: () => service.toggleStore(entry.store),
                            ),
                          ),
                        Marker(
                          point: location,
                          width: _UserMarker.size,
                          height: _UserMarker.size,
                          child: const _UserMarker(),
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        for (final entry in visible)
                          Marker(
                            key: ValueKey('label-${entry.store.id}'),
                            point: entry.store.position,
                            width: _StoreMarkerBadge.width,
                            height: _StoreMarkerBadge.height,
                            alignment: Alignment.topCenter,
                            rotate: true,
                            child: _StoreMarkerLabel(
                              store: entry.store,
                              kilometres: entry.kilometres,
                              onTap: () => service.toggleStore(entry.store),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                if (!trayExpanded)
                  _RecenterButton(onTap: onRecenter)
                      .positioned(right: TwSpacing.s4, bottom: bottom),
                if (message != null)
                  _Notice(text: message).positioned(
                    left: TwSpacing.s4,
                    right: TwSpacing.s4,
                    bottom:
                        bottom + _SelectedTray.collapsedHeight + TwSpacing.s2,
                  ),
                if (entries.isNotEmpty)
                  _SelectedTray(
                    entries: entries,
                    expanded: trayExpanded,
                    onToggle: service.toggleTray,
                    onRemove: service.toggleStore,
                    onReset: service.resetSelected,
                  ).positioned(
                    left: TwSpacing.s4,
                    right: TwSpacing.s4,
                    bottom: bottom,
                    height: _SelectedTray.boxHeight,
                  ),
                if (searching)
                  TextFieldTapRegion(
                    child: _SearchResults(
                      results: service.results.value,
                      selectedIds: selectedIds,
                      onToggle: service.toggleStore,
                    ),
                  ).positioned(
                    top: resultsTop,
                    left: TwSpacing.s4,
                    right: TwSpacing.s4,
                    bottom: entries.isEmpty
                        ? bottom
                        : bottom + _SelectedTray.collapsedHeight + TwSpacing.s2,
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

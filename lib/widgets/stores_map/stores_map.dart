import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:latlong2/latlong.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../models/store_location.dart';
import '../../nav/nav_metrics.dart';
import '../../service_locator.dart';
import '../../services/device_permission_service.dart';
import '../../services/stores_screen_service.dart';
import '../../theme/theme.dart';
import '../../utils/geo_util.dart';
import '../app_glass_button.dart';
import '../permission_denied.dart';
import '../no_perms_view.dart';
import '../supermarket_logo.dart';

part 'common/error_state.dart';
part 'common/notice.dart';
part 'common/recenter_button.dart';
part 'common/search_results.dart';
part 'common/selected_tray.dart';
part 'common/store_marker.dart';
part 'common/stores_map_view.dart';
part 'common/user_marker.dart';

const double _hairline = 0.5;

BoxDecoration _panel(AppColors colors, {double radius = TwRadius.xl2}) {
  return BoxDecoration(
    color: colors.surface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: colors.border, width: _hairline),
    boxShadow: [
      BoxShadow(
        color: colors.textPrimary.withValues(alpha: 0.08),
        blurRadius: TwSpacing.s2,
      ),
    ],
  );
}

class StoresMap extends StatefulWidget {
  const StoresMap({super.key, required this.contentTop});

  final double contentTop;

  @override
  State<StoresMap> createState() => _StoresMapState();
}

class _StoresMapState extends State<StoresMap> {
  final _service = getIt<StoresScreenService>();
  final _mapController = MapController();
  ValueListenable<TickerModeData>? _active;

  @override
  void initState() {
    super.initState();
    _service.load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = TickerMode.getValuesNotifier(context);
    if (identical(next, _active)) return;
    _active?.removeListener(_onActiveChanged);
    _active = next..addListener(_onActiveChanged);
  }

  void _onActiveChanged() {
    if (_active?.value.enabled ?? false) _service.load();
  }

  Future<void> _recenter() async {
    final location = await _service.recenter();
    if (location == null || !mounted) return;
    _mapController.rotate(0);
    _mapController.fitCamera(
      _StoresMapView.defaultFit(location, _service.visible.value),
    );
  }

  @override
  void dispose() {
    _active?.removeListener(_onActiveChanged);
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        final status = _service.status.value;
        return switch (status) {
          StoresMapStatus.loading => const Center(
            child: CircularProgressIndicator(color: BrandColors.accent500),
          ),
          StoresMapStatus.ready => _StoresMapView(
            service: _service,
            mapController: _mapController,
            contentTop: widget.contentTop,
            onRecenter: _recenter,
          ),
          _ => _ErrorState(status: status, onRetry: _service.retry),
        };
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../service_locator.dart';
import '../services/stores_screen_service.dart';
import 'app_header.dart';
import 'stores_filter_bar.dart';

class StoresHeader extends StatelessWidget {
  const StoresHeader({super.key});

  static double heightOf(BuildContext context) =>
      AppHeader.heightOf(context) + StoresFilterBar.height;

  @override
  Widget build(BuildContext context) {
    final service = getIt<StoresScreenService>();
    final width = MediaQuery.sizeOf(context).width;
    return SizedBox(
      width: width,
      height: AppHeader.height + StoresFilterBar.height,
      child: Column(
        children: [
          AppHeader(
            showActions: false,
            hintText: 'Search stores',
            onChanged: service.onSearchChanged,
            onFocusChanged: service.searchFocused.set,
          ),
          SignalBuilder(
            builder: (context) => StoresFilterBar(
              filters: service.filters.value,
              onToggle: service.toggleFilter,
              onClear: service.clearFilters,
            ),
          ),
        ],
      ),
    );
  }
}

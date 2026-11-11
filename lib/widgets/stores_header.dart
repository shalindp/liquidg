import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:styled_widget/styled_widget.dart';

import '../service_locator.dart';
import '../services/stores_screen_service.dart';
import '../theme/theme.dart';
import 'app_glass_button.dart';
import 'app_header.dart';
import 'stores_filters_sheet.dart';

class StoresHeader extends StatelessWidget {
  const StoresHeader({super.key});

  static const double _dot = TwSpacing.s3;

  static double heightOf(BuildContext context) => AppHeader.heightOf(context);

  @override
  Widget build(BuildContext context) {
    final service = getIt<StoresScreenService>();
    final colors = context.colors;
    return AppHeader(
      showActions: false,
      hintText: 'Search stores',
      onChanged: service.onSearchChanged,
      onFocusChanged: service.searchFocused.set,
      trailing: Stack(
        clipBehavior: Clip.none,
        children: [
          AppGlassButton(
            size: AppHeader.height,
            onPressed: () => showStoresFiltersSheet(context),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedFilterVertical,
              color: colors.textPrimary,
              size: 22,
            ),
          ),
          SignalBuilder(
            builder: (context) {
              if (service.activeFilterCount.value == 0) {
                return const SizedBox.shrink();
              }
              return IgnorePointer(
                child: const SizedBox(width: _dot, height: _dot).decorated(
                  color: BrandColors.accent500,
                  shape: BoxShape.circle,
                  border: Border.all(color: TwColors.white, width: 1.5),
                ),
              );
            },
          ).positioned(top: TwSpacing.s0_5, right: TwSpacing.s0_5),
        ],
      ),
    );
  }
}

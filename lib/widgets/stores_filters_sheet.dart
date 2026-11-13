import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart'
    show LiquidGlassSlider, LiquidGlassSwitch, LiquidGlassSwitchLayout;
import 'package:signals_flutter/signals_flutter.dart';
import 'package:styled_widget/styled_widget.dart';

import '../models/supermarket.dart';
import '../service_locator.dart';
import '../services/stores_screen_service.dart';
import '../theme/theme.dart';
import 'supermarket_logo.dart';

Future<void> showStoresFiltersSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => const _StoresFiltersSheet(),
  );
}

class _StoresFiltersSheet extends StatelessWidget {
  const _StoresFiltersSheet();

  static const double _hairline = 0.5;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final service = getIt<StoresScreenService>();
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    return SignalBuilder(
      builder: (context) {
        final filters = service.filters.value;
        final radius = service.radiusKm.value;
        final active = service.activeFilterCount.value > 0;
        final count = service.visible.value.length;
        final counts = service.chainCounts.value;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  'Filters',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: TwFontSize.xl,
                    fontWeight: TwFontWeight.bold,
                  ),
                ).expanded(),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 160),
                  opacity: active ? 1 : 0,
                  child: IgnorePointer(
                    ignoring: !active,
                    child:
                        Text(
                              'Reset',
                              style: TextStyle(
                                color: colors.danger,
                                fontSize: TwFontSize.sm,
                                fontWeight: TwFontWeight.medium,
                              ),
                            )
                            .padding(vertical: TwSpacing.s2)
                            .gestures(
                              behavior: HitTestBehavior.opaque,
                              onTap: service.resetFilters,
                            ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: TwSpacing.s5),
            const _SectionHeader(title: 'Supermarkets'),
            const SizedBox(height: TwSpacing.s3),
            _SupermarketList(
              filters: filters,
              counts: counts,
              radius: radius,
              service: service,
            ),
            const SizedBox(height: TwSpacing.s6),
            _SectionHeader(
              title: 'Distance',
              value: radius == null ? '30+ km' : '${radius.round()} km',
            ),
            const SizedBox(height: TwSpacing.s2),
            LayoutBuilder(
              builder: (context, constraints) => LiquidGlassSlider(
                width: constraints.maxWidth,
                minimumValue: StoresScreenService.minRadiusKm,
                maximumValue: StoresScreenService.maxRadiusKm,
                value: radius ?? StoresScreenService.maxRadiusKm,
                activeColor: BrandColors.accent500,
                onChanged: (value) => service.setRadius(value.roundToDouble()),
              ),
            ),
            Row(
              children: [
                _EndLabel('${StoresScreenService.minRadiusKm.round()} km'),
                const Spacer(),
                _EndLabel('${StoresScreenService.maxRadiusKm.round()}+ km'),
              ],
            ),
            const SizedBox(height: TwSpacing.s6),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                overlayColor: Colors.transparent,
                splashFactory: NoSplash.splashFactory,
                backgroundColor: BrandColors.accent500,
                foregroundColor: colors.textOnAccent,
                minimumSize: const Size.fromHeight(TwSpacing.s14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(TwRadius.xl2),
                ),
                textStyle: const TextStyle(
                  fontSize: TwFontSize.base,
                  fontWeight: TwFontWeight.semibold,
                ),
              ),
              child: Text(count == 1 ? 'Show 1 store' : 'Show $count stores'),
            ),
          ],
        ).padding(
          left: TwSpacing.s4,
          right: TwSpacing.s4,
          bottom: TwSpacing.s4 + bottomInset,
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.value});

  final String title;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            color: colors.textPrimary.withValues(alpha: 0.6),
            fontSize: TwFontSize.xs,
            fontWeight: TwFontWeight.semibold,
            letterSpacing: 0.8,
          ),
        ).expanded(),
        if (value != null)
          Text(
            value!,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: TwFontSize.xl2,
              fontWeight: TwFontWeight.bold,
              height: 1,
            ),
          ),
      ],
    );
  }
}

class _EndLabel extends StatelessWidget {
  const _EndLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: context.colors.textPrimary.withValues(alpha: 0.6),
        fontSize: TwFontSize.xs,
        fontWeight: TwFontWeight.medium,
      ),
    );
  }
}

class _SupermarketList extends StatelessWidget {
  const _SupermarketList({
    required this.filters,
    required this.counts,
    required this.radius,
    required this.service,
  });

  static const double _logo = TwSpacing.s6;

  final Set<Supermarket> filters;
  final Map<Supermarket, int> counts;
  final double? radius;
  final StoresScreenService service;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final all = filters.isEmpty;
    final rows = [
      _SupermarketRow(
        leading: SvgPicture.asset(
          'assets/icons/grid.svg',
          width: TwSpacing.s4,
          height: TwSpacing.s4,
          colorFilter: ColorFilter.mode(colors.textPrimary, BlendMode.srcIn),
        ).center().constrained(width: _logo, height: _logo),
        title: 'All supermarkets',
        subtitle: radius == null
            ? '${counts.values.fold(0, (a, b) => a + b)} stores'
            : '${counts.values.fold(0, (a, b) => a + b)} stores within '
                  '${radius!.round()} km',
        value: all,
        muted: false,
        onChanged: (on) => service.setAllSupermarkets(on: on),
      ),
      for (final chain in Supermarket.values)
        _SupermarketRow(
          leading: SupermarketLogo(chain: chain, size: _logo),
          title: chain.label,
          subtitle: _count(counts[chain] ?? 0),
          value: filters.contains(chain),
          muted: all,
          onChanged: (_) => service.toggleFilter(chain),
        ),
    ];
    return Column(
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0)
            const SizedBox(height: _StoresFiltersSheet._hairline)
                .backgroundColor(colors.border),
          rows[i],
        ],
      ],
    ).decorated(
      color: colors.surfaceMuted,
      borderRadius: BorderRadius.circular(TwRadius.xl2),
    );
  }

  String _count(int count) {
    final noun = count == 1 ? 'store' : 'stores';
    return radius == null
        ? '$count $noun'
        : '$count $noun within ${radius!.round()} km';
  }
}

class _SupermarketRow extends StatelessWidget {
  const _SupermarketRow({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.muted,
    required this.onChanged,
  });

  static const Duration _animation = Duration(milliseconds: 180);

  final Widget leading;
  final String title;
  final String subtitle;
  final bool value;
  final bool muted;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedOpacity(
      duration: _animation,
      opacity: muted ? 0.4 : 1,
      child: Row(
        spacing: TwSpacing.s2_5,
        children: [
          leading,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: TwFontSize.sm,
                  fontWeight: TwFontWeight.medium,
                ),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: TwFontSize.xs,
                ),
              ),
            ],
          ).expanded(),
          LiquidGlassSwitch(
            value: value,
            activeColor: BrandColors.accent500,
            layout: const LiquidGlassSwitchLayout(
              width: 52,
              height: 27,
              thumbWidth: 32,
              thumbHeight: 23,
              expandedThumbWidth: 50,
              expandedThumbHeight: 38,
              pinchedHeight: 21,
            ),
            onChanged: onChanged,
          ),
        ],
      ).padding(horizontal: TwSpacing.s3, vertical: TwSpacing.s2),
    );
  }
}

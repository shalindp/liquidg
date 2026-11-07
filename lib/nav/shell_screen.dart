import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';

import '../theme/theme.dart';
import '../widgets/chrome_collapse_controller.dart';
import '../widgets/collapsing_header.dart';
import 'nav_tab.dart';
import 'routes.dart';

LiquidGlassTabBarItem _tab(String asset, String? label, {double scale = 1}) {
  return LiquidGlassTabBarItem(
    label: label,
    iconBuilder: (context, glyph) => SvgPicture.asset(
      asset,
      width: glyph.size * scale,
      height: glyph.size * scale,
      colorFilter: ColorFilter.mode(
        glyph.selected ? glyph.color : context.colors.iconInactive,
        BlendMode.srcIn,
      ),
    ),
  );
}

final _tabs = <LiquidGlassTabBarItem>[
  for (final tab in NavTab.values) _tab(tab.icon, tab.route.title),
];

final _iconOnlyTabs = <LiquidGlassTabBarItem>[
  for (final tab in NavTab.values)
    _tab(tab.icon, null, scale: _circle / _navHeight),
];

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

LiquidGlassStyle _foldedStyle(LiquidGlassStyle base) => base.copyWith(
  specular: const LiquidGlassLight.specular(intensity: 0, oppositeIntensity: 0),
);

const double _navHeight = 68;
const double _circle = CollapsingHeader.controlSize;

class _ShellScreenState extends State<ShellScreen> {
  final _chrome = ChromeCollapseController();

  @override
  void dispose() {
    _chrome.dispose();
    super.dispose();
  }

  void _select(int i) {
    final shell = widget.navigationShell;
    _chrome.expand();
    shell.goBranch(i, initialLocation: i == shell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final index = widget.navigationShell.currentIndex;
    final route =
        AppRoute.matching(GoRouterState.of(context).uri.path) ??
        NavTab.values[index].route;
    final products = route == AppRoute.products;

    final navBottom = math.max(
      TwSpacing.s2,
      MediaQuery.viewPaddingOf(context).bottom + TwSpacing.s2 - TwSpacing.s4,
    );
    final barStyle = Theme.brightnessOf(context) == Brightness.dark
        ? LiquidGlassTabBar.defaultDarkStyle
        : LiquidGlassTabBar.defaultStyle;
    final fullWidth = (width - TwSpacing.s8).clamp(240.0, 420.0);

    return ValueListenableBuilder<bool>(
      valueListenable: _chrome,
      builder: (context, collapsed, _) => TweenAnimationBuilder<double>(
        tween: Tween(end: collapsed ? _circle : fullWidth),
        duration: collapsed ? CollapsingHeader.collapseDuration : Duration.zero,
        curve: Curves.easeOutCubic,
        builder: (context, barWidth, _) {
          final progress = ((fullWidth - barWidth) / (fullWidth - _circle))
              .clamp(0.0, 1.0);
          final folded = barWidth < fullWidth * 0.55;
          return LiquidGlassScaffold(
            backgroundColor: context.colors.background,
            safeArea: false,
            appBar: products
                ? CollapsingHeader(
                    collapsed: collapsed,
                    onExpand: _chrome.expand,
                  )
                : LiquidGlassAppBar(
                    title: Text(route.title),
                    width: width - 32,
                  ),
            appBarTopMargin:
                MediaQuery.viewPaddingOf(context).top + TwSpacing.s2,
            lenses: [
              if (products)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: CollapsingHeader.heightOf(context) + TwSpacing.s2,
                  child: IgnorePointer(
                    child: AnimatedOpacity(
                      opacity: collapsed ? 0 : 1,
                      duration: collapsed
                          ? CollapsingHeader.collapseDuration
                          : Duration.zero,
                      child: ColoredBox(color: context.colors.background),
                    ),
                  ),
                ),
            ],
            body: NotificationListener<ScrollNotification>(
              onNotification: _chrome.onScroll,
              child: widget.navigationShell,
            ),
            bottomNavigationBar: LiquidGlassTabBar(
              items: folded ? [_iconOnlyTabs[index]] : _tabs,
              selectedIndex: folded ? 0 : index,
              onChanged: _select,
              onReselected: folded ? (_) => _chrome.expand() : null,
              width: barWidth,
              height: _navHeight - (_navHeight - _circle) * progress,
              alignment: Alignment(-progress, 1),
              margin: EdgeInsets.fromLTRB(
                16 + (TwSpacing.s1 + TwSpacing.s2) * progress,
                0,
                16,
                navBottom,
              ),
              style: folded ? _foldedStyle(barStyle) : barStyle,
              pillStyle: LiquidGlassTabPillStyle(show: !folded),
              itemStyle: LiquidGlassTabItemStyle(
                selectedColor: BrandColors.accent500,
                unselectedColor: context.colors.labelInactive,
              ),
            ),
          );
        },
      ),
    );
  }
}

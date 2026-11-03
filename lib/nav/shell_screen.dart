import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/theme.dart';
import '../widgets/search_header.dart';
import 'nav_tab.dart';
import 'routes.dart';

LiquidGlassTabBarItem _tab(String asset, String label) {
  return LiquidGlassTabBarItem(
    label: label,
    iconBuilder: (context, glyph) => SvgPicture.asset(
      asset,
      width: glyph.size,
      height: glyph.size,
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

class ShellScreen extends StatelessWidget {
  const ShellScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final index = navigationShell.currentIndex;
    final route =
        AppRoute.matching(GoRouterState.of(context).uri.path) ??
        NavTab.values[index].route;
    return LiquidGlassScaffold(
      backgroundColor: context.colors.background,
      appBar: route == AppRoute.products
          ? const SearchHeader()
          : LiquidGlassAppBar(title: Text(route.title), width: width - 32),
      appBarTopMargin: route == AppRoute.products
          ? -MediaQuery.viewPaddingOf(context).top
          : 8,
      body: navigationShell,
      bottomNavigationBar: LiquidGlassTabBar(
        items: _tabs,
        selectedIndex: index,
        onChanged: (i) =>
            navigationShell.goBranch(i, initialLocation: i == index),
        width: (width - 32).clamp(240, 420),
        height: 68,
        margin: const EdgeInsets.only(bottom: TwSpacing.s2),
        style: Theme.brightnessOf(context) == Brightness.dark
            ? LiquidGlassTabBar.defaultDarkStyle
            : LiquidGlassTabBar.defaultStyle,
        itemStyle: LiquidGlassTabItemStyle(
          selectedColor: BrandColors.accent500,
          unselectedColor: context.colors.labelInactive,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/theme.dart';

LiquidGlassTabBarItem _tab(String asset, String label) {
  return LiquidGlassTabBarItem(
    label: label,
    iconBuilder: (context, glyph) => SvgPicture.asset(
      asset,
      width: glyph.size,
      height: glyph.size,
      colorFilter: ColorFilter.mode(glyph.color, BlendMode.srcIn),
    ),
  );
}

final _tabs = <LiquidGlassTabBarItem>[
  _tab('assets/icons/nav/stores.svg', 'Stores'),
  _tab('assets/icons/nav/products.svg', 'Products'),
  _tab('assets/icons/nav/lists.svg', 'Lists'),
  _tab('assets/icons/nav/more.svg', 'More'),
];

class ShellScreen extends StatelessWidget {
  const ShellScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final dark = Theme.brightnessOf(context) == Brightness.dark;
    final index = navigationShell.currentIndex;
    final onFeatures = GoRouterState.of(context).uri.path.endsWith('/features');
    return LiquidGlassScaffold(
      backgroundColor: context.colors.background,
      appBar: LiquidGlassAppBar(
        title: Text(onFeatures ? 'Features' : _tabs[index].label!),
        width: width - 32,
      ),
      appBarTopMargin: 8,
      body: navigationShell,
      bottomNavigationBar: LiquidGlassTabBar(
        items: _tabs,
        selectedIndex: index,
        onChanged: (i) =>
            navigationShell.goBranch(i, initialLocation: i == index),
        width: (width - 32).clamp(240, 420),
        height: 68,
        margin: const EdgeInsets.only(bottom: TwSpacing.s2),
        style: dark
            ? LiquidGlassTabBar.defaultDarkStyle
            : LiquidGlassTabBar.defaultStyle,
        itemStyle: LiquidGlassTabItemStyle(
          selectedColor: BrandColors.accent500,
          unselectedColor: TwColors.neutral.s900,
        ),
      ),
    );
  }
}

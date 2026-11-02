import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:mix/mix.dart';

import 'theme/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Skia/GLES devices (e.g. OnePlus 3T): cheap no-shader glass.
  // Impeller devices keep the full refraction shader.
  LiquidGlassEngine.liteGlassOnSkia = true;
  if (ui.ImageFilter.isShaderFilterSupported) {
    await LiquidGlassShaders.ensureLoaded();
  }
  runApp(const MyApp());
}

/// App-wide theme choice. Follows the system unless changed.
final themeController = ThemeController();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeController,
      builder: (context, mode, _) => MaterialApp(
        title: 'UX App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: mode,
        builder: (context, child) => AppMixScope(child: child!),
        home: const HomeScreen(),
      ),
    );
  }
}

LiquidGlassTabBarItem _tab(List<List<dynamic>> icon, String label) {
  return LiquidGlassTabBarItem(
    label: label,
    iconBuilder: (context, glyph) => HugeIcon(
      icon: icon,
      color: glyph.color,
      size: glyph.size,
      // No solid set in the free pack: thicken the stroke when selected.
      strokeWidth: glyph.selected ? 2.2 : 1.5,
    ),
  );
}

final _tabs = <LiquidGlassTabBarItem>[
  _tab(HugeIcons.strokeRoundedHome01, 'Home'),
  _tab(HugeIcons.strokeRoundedCompass01, 'Explore'),
  _tab(HugeIcons.strokeRoundedFavourite, 'Saved'),
  _tab(HugeIcons.strokeRoundedUser, 'Profile'),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final dark = Theme.brightnessOf(context) == Brightness.dark;
    return LiquidGlassScaffold(
      backgroundColor: context.colors.background,
      appBar: LiquidGlassAppBar(
        title: Text(_tabs[_index].label!),
        width: width - 32,
      ),
      appBarTopMargin: 8,
      body: CardList(key: ValueKey(_index), seed: _index),
      bottomNavigationBar: LiquidGlassTabBar(
        items: _tabs,
        selectedIndex: _index,
        onChanged: (i) => setState(() => _index = i),
        width: (width - 32).clamp(240, 420),
        style: dark
            ? LiquidGlassTabBar.defaultDarkStyle
            : LiquidGlassTabBar.defaultStyle,
        itemStyle: dark
            ? LiquidGlassTabItemStyle(
                selectedColor: LiquidGlassTabItemStyle.defaultSelectedDark,
                unselectedColor: Colors.white,
              )
            : const LiquidGlassTabItemStyle(),
      ),
    );
  }
}

class CardList extends StatelessWidget {
  const CardList({super.key, required this.seed});

  final int seed;

  static final _palette = <Color>[
    TwColors.red.s400,
    TwColors.amber.s400,
    TwColors.teal.s400,
    TwColors.blue.s400,
    TwColors.violet.s400,
    TwColors.pink.s400,
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      // Room for glass app bar on top and tab bar at bottom.
      padding: const EdgeInsets.fromLTRB(
        TwSpacing.s4,
        TwSpacing.s24 - TwSpacing.s2,
        TwSpacing.s4,
        TwSpacing.s28 + TwSpacing.s2,
      ),
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      itemCount: 20,
      separatorBuilder: (_, _) => const SizedBox(height: TwSpacing.s4),
      itemBuilder: (context, i) => PlaceholderCard(
        color: _palette[(i + seed) % _palette.length],
        title: 'Placeholder card ${i + 1}',
        subtitle: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
      ),
    );
  }
}

class PlaceholderCard extends StatelessWidget {
  const PlaceholderCard({
    super.key,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cardStyle = BoxStyler()
        .height(120)
        .padding(.all($space4()))
        .borderRadius(.all($radius3xl()))
        .color(color)
        .onPressed(.color(color.withValues(alpha: 0.85)));

    final titleStyle = TextStyler()
        .fontSize(18)
        .fontWeight(.w700)
        .color(Colors.white);
    final subtitleStyle = TextStyler()
        .fontSize(14)
        .color(Colors.white.withValues(alpha: 0.85))
        .maxLines(2);

    return cardStyle.pressable(
      onPress: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StyledText(title, style: titleStyle),
          const SizedBox(height: 6),
          StyledText(subtitle, style: subtitleStyle),
        ],
      ),
    );
  }
}

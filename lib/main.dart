import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:mix/mix.dart';

import 'theme/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LiquidGlassEngine.liteGlassOnSkia = true;
  if (ui.ImageFilter.isShaderFilterSupported) {
    await LiquidGlassShaders.ensureLoaded();
  }
  runApp(const MyApp());
}

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

LiquidGlassTabBarItem _tab(IconData icon, IconData filled, String label) {
  return LiquidGlassTabBarItem(label: label, icon: icon, selectedIcon: filled);
}

final _tabs = <LiquidGlassTabBarItem>[
  _tab(PhosphorIconsRegular.house, PhosphorIconsFill.house, 'Home'),
  _tab(PhosphorIconsRegular.compass, PhosphorIconsFill.compass, 'Explore'),
  _tab(PhosphorIconsRegular.heart, PhosphorIconsFill.heart, 'Saved'),
  _tab(PhosphorIconsRegular.user, PhosphorIconsFill.user, 'Profile'),
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
        height: 68,
        margin: const EdgeInsets.only(bottom: TwSpacing.s2),
        style: dark
            ? LiquidGlassTabBar.defaultDarkStyle
            : LiquidGlassTabBar.defaultStyle,
        itemStyle: LiquidGlassTabItemStyle(
          selectedColor: dark ? TwColors.white : TwColors.black,
          unselectedColor: dark ? TwColors.zinc.s400 : TwColors.zinc.s600,
        ),
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

import 'package:flutter/material.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:mix/mix.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassShaders.ensureLoaded();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UX App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0088FF)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

const _tabs = <LiquidGlassTabBarItem>[
  LiquidGlassTabBarItem(
    icon: Icons.home_outlined,
    selectedIcon: Icons.home_rounded,
    label: 'Home',
  ),
  LiquidGlassTabBarItem(
    icon: Icons.explore_outlined,
    selectedIcon: Icons.explore_rounded,
    label: 'Explore',
  ),
  LiquidGlassTabBarItem(
    icon: Icons.favorite_border_rounded,
    selectedIcon: Icons.favorite_rounded,
    label: 'Saved',
  ),
  LiquidGlassTabBarItem(
    icon: Icons.person_outline_rounded,
    selectedIcon: Icons.person_rounded,
    label: 'Profile',
  ),
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
    return LiquidGlassScaffold(
      backgroundColor: const Color(0xFFF2F2F7),
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
      ),
    );
  }
}

class CardList extends StatelessWidget {
  const CardList({super.key, required this.seed});

  final int seed;

  static const _palette = <Color>[
    Color(0xFFFF6B6B),
    Color(0xFFFFB84D),
    Color(0xFF4ECDC4),
    Color(0xFF5B8DEF),
    Color(0xFFA06CD5),
    Color(0xFFFF7EB6),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      // Room for glass app bar on top and tab bar at bottom.
      padding: const EdgeInsets.fromLTRB(16, 88, 16, 120),
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      itemCount: 20,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
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
        .padding(.all(16))
        .borderRadius(.circular(24))
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

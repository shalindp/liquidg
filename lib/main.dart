import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:ominicart_api/ominicart_api.dart';

import 'config/env.dart';
import 'query/query.dart';
import 'router.dart';
import 'theme/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LiquidGlassEngine.liteGlassOnSkia = true;
  if (ui.ImageFilter.isShaderFilterSupported) {
    await LiquidGlassShaders.ensureLoaded();
  }
  final env = await Env.load();
  api = OminicartApi(basePathOverride: env.apiBaseUrl);
  query = Query();
  runApp(const MyApp());
}

late final OminicartApi api;
late final Query query;

final themeController = ThemeController();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeController,
      builder: (context, mode, _) => MaterialApp.router(
        title: 'UX App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: mode,
        routerConfig: router,
        builder: (context, child) => AppMixScope(child: child!),
      ),
    );
  }
}

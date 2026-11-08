import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';

import 'config/env.dart';
import 'query/query.dart';
import 'router.dart';
import 'service_locator.dart';
import 'services/client_service.dart';
import 'services/products_screen_service.dart';
import 'services/query_service.dart';
import 'theme/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LiquidGlassEngine.liteGlassOnSkia = true;
  if (ui.ImageFilter.isShaderFilterSupported) {
    await LiquidGlassShaders.ensureLoaded();
  }
  final env = await Env.load();
  getIt.registerSingleton<ClientService>(ClientService(env));
  getIt.registerSingleton<QueryService>(
    QueryService(getIt<ClientService>(), Query()),
    dispose: (service) => service.dispose(),
  );
  getIt.registerSingleton<ProductsScreenService>(
    ProductsScreenService(getIt<QueryService>()),
    dispose: (service) => service.dispose(),
  );
  runApp(const MyApp());
}

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

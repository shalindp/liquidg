import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'nav/routes.dart';
import 'nav/shell_screen.dart';
import 'screens/basket_screen.dart';
import 'screens/features_screen.dart';
import 'screens/lists_screen.dart';
import 'screens/more_screen.dart';
import 'screens/products_screen.dart';
import 'screens/stores_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoute.products.path,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          ShellScreen(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoute.stores.path,
              builder: (context, state) => const StoresScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoute.products.path,
              builder: (context, state) => const ProductsScreen(),
              routes: [
                GoRoute(
                  path: AppRoute.basket.segment,
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) => const BasketScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoute.lists.path,
              builder: (context, state) => const ListsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoute.more.path,
              builder: (context, state) => const MoreScreen(),
              routes: [
                GoRoute(
                  path: AppRoute.features.segment,
                  builder: (context, state) => const FeaturesScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

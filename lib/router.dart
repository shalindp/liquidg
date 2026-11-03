import 'package:go_router/go_router.dart';

import 'screens/features_screen.dart';
import 'screens/lists_screen.dart';
import 'screens/more_screen.dart';
import 'screens/products_screen.dart';
import 'screens/shell_screen.dart';
import 'screens/stores_screen.dart';

final router = GoRouter(
  initialLocation: '/stores',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          ShellScreen(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/stores',
              builder: (context, state) => const StoresScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/products',
              builder: (context, state) => const ProductsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/lists',
              builder: (context, state) => const ListsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/more',
              builder: (context, state) => const MoreScreen(),
              routes: [
                GoRoute(
                  path: 'features',
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

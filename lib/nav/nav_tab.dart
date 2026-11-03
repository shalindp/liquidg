import 'routes.dart';

enum NavTab {
  stores(AppRoute.stores, 'assets/icons/nav/stores.svg'),
  products(AppRoute.products, 'assets/icons/nav/products.svg'),
  lists(AppRoute.lists, 'assets/icons/nav/lists.svg'),
  more(AppRoute.more, 'assets/icons/nav/more.svg');

  const NavTab(this.route, this.icon);

  final AppRoute route;
  final String icon;
}

enum AppRoute {
  stores('/stores', 'Stores'),
  products('/products', 'Products'),
  lists('/lists', 'Lists'),
  more('/more', 'More'),
  features('/more/features', 'Features');

  const AppRoute(this.path, this.title);

  final String path;
  final String title;

  String get segment => path.split('/').last;

  static AppRoute? matching(String path) {
    for (final route in values) {
      if (route.path == path) return route;
    }
    return null;
  }
}

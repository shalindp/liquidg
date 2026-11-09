enum ProductSort {
  relevance('Relevance', null, true),
  boughtBefore('Bought before', null, false),
  priceAscending('Price', 'Low to High', true),
  priceDescending('Price', 'High to Low', true),
  unitPriceAscending('Unit Price', 'Low to High', false);

  const ProductSort(this.title, this.subtitle, this.available);

  final String title;
  final String? subtitle;
  final bool available;
}

enum ProductView { grid, list }

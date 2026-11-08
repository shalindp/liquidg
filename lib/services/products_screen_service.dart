import 'dart:async';

import 'package:ominicart_api/ominicart_api.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../models/product_item.dart';
import '../models/selected_store.dart';
import '../models/supermarket.dart';
import 'client_service.dart';
import 'query_service.dart';

class ProductsScreenService {
  ProductsScreenService(this._client, this._queries);

  static const int pageSize = 8;
  static const int maxQuantity = 99;
  static const String initialSearchTerm = 'cheese';
  static const Duration searchDebounce = Duration(milliseconds: 350);
  static const int _centsPerDollar = 100;
  static final RegExp _leadingNumber = RegExp(r'^#\d+\s*');
  static final RegExp _primaryImage = RegExp(r'_1\.webp$');

  static const selectedStores = <SelectedStore>[
    SelectedStore(
      id: 159,
      supermarket: Supermarket.woolworths,
      branch: 'Glenfield',
    ),
    SelectedStore(
      id: 158,
      supermarket: Supermarket.woolworths,
      branch: 'Northcote',
    ),
    SelectedStore(
      id: 160,
      supermarket: Supermarket.woolworths,
      branch: 'Takapuna',
    ),
    SelectedStore(id: 208, supermarket: Supermarket.paknsave, branch: 'Albany'),
    SelectedStore(
      id: 203,
      supermarket: Supermarket.paknsave,
      branch: 'Silverdale',
    ),
    SelectedStore(id: 291, supermarket: Supermarket.newWorld, branch: 'Albany'),
    SelectedStore(
      id: 264,
      supermarket: Supermarket.newWorld,
      branch: 'Browns Bay',
    ),
  ];

  final ClientService _client;
  final QueryService _queries;

  final quantities = signal<Map<String, int>>(const {});
  late final totalCount = computed(
    () => quantities.value.values.fold(0, (sum, count) => sum + count),
  );

  final products = signal<List<ProductItem>>(const []);
  final loading = signal(false);
  final error = signal<Object?>(null);
  final hasMore = signal(true);

  int quantityOf(String productId) => quantities.value[productId] ?? 0;

  void setQuantity(String productId, int quantity) {
    final next = quantity.clamp(0, maxQuantity);
    final updated = {...quantities.value};
    if (next == 0) {
      updated.remove(productId);
    } else {
      updated[productId] = next;
    }
    quantities.value = updated;
  }

  Timer? _debounce;
  String _searchTerm = initialSearchTerm;
  int _skip = 0;
  int _generation = 0;
  bool _disposed = false;

  String get searchTerm => _searchTerm;

  void onSearchChanged(String term) {
    _debounce?.cancel();
    _debounce = Timer(searchDebounce, () => search(term));
  }

  Future<void> search(String term) {
    final trimmed = term.trim();
    final next = trimmed.isEmpty ? initialSearchTerm : trimmed;
    if (next == _searchTerm) return Future.value();
    _searchTerm = next;
    return _reset();
  }

  Future<void> refresh() => _reset(force: true);

  Future<void> _reset({bool force = false}) {
    _generation++;
    _skip = 0;
    products.value = const [];
    loading.value = false;
    error.value = null;
    hasMore.value = true;
    return loadMore(force: force);
  }

  Future<void> loadMore({bool force = false}) async {
    if (_disposed || loading.value || !hasMore.value) return;
    final generation = _generation;
    loading.value = true;
    error.value = null;
    final query = _queries.useGetProducts(
      searchTerm: _searchTerm,
      skip: _skip,
      limit: pageSize,
      storeIds: [for (final store in selectedStores) store.id],
    );
    try {
      final page = await query.trigger(force: force);
      if (_disposed || generation != _generation) return;
      if (page == null) {
        final failure = query.$error.value;
        if (failure != null) {
          error.value = failure;
        } else {
          hasMore.value = false;
        }
        return;
      }
      final received = page.products;
      products.value = [
        ...products.value,
        for (final product in received) ?_toItem(product),
      ];
      _skip = page.skip + received.length;
      hasMore.value = received.isNotEmpty && _skip < page.total;
    } catch (failure) {
      if (!_disposed && generation == _generation) error.value = failure;
    } finally {
      query.dispose();
      if (!_disposed && generation == _generation) loading.value = false;
    }
  }

  ProductItem? _toItem(ProductSummary product) {
    final priced = <StorePrice>[];
    final unavailable = <StorePrice>[];
    for (final store in selectedStores) {
      final cents = _cents(product, store.id);
      final entry = StorePrice(
        chain: store.supermarket,
        branch: store.branch,
        price: cents == null ? null : cents / _centsPerDollar,
      );
      (cents == null ? unavailable : priced).add(entry);
    }
    if (priced.isEmpty) return null;
    priced.sort((a, b) => a.price!.compareTo(b.price!));
    final stores = [...priced, ...unavailable];
    return ProductItem(
      id: product.productId,
      name: product.name.replaceFirst(_leadingNumber, ''),
      packSize: product.packSize,
      imageUrl: _imageUrl(product),
      stores: stores,
    );
  }

  int? _cents(ProductSummary product, int storeId) {
    for (final price in product.prices) {
      if (price.retailerRegionId == storeId) return price.cents;
    }
    return null;
  }

  String? _imageUrl(ProductSummary product) {
    final images = product.imageUrls;
    if (images.isEmpty) return null;
    final path = images.firstWhere(
      _primaryImage.hasMatch,
      orElse: () => images.first,
    );
    return Uri.parse(_client.baseUrl).resolve(path).toString();
  }

  void dispose() {
    _disposed = true;
    _debounce?.cancel();
    _generation++;
    totalCount.dispose();
    quantities.dispose();
    products.dispose();
    loading.dispose();
    error.dispose();
    hasMore.dispose();
  }
}

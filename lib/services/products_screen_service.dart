import 'dart:async';

import 'package:ominicart_api/ominicart_api.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../models/product_filters.dart';
import '../models/product_item.dart';
import '../models/store_location.dart';
import '../query/query.dart';
import 'client_service.dart';
import 'query_service.dart';
import 'stores_service.dart';

class ProductsScreenService {
  ProductsScreenService(this._client, this._queries, this._stores) {
    _disposeSelection = _stores.appliedIds.subscribe((_) {
      if (_selectionSeen) _reset();
      _selectionSeen = true;
    });
  }

  static const int pageSize = 8;
  static const int maxQuantity = 99;
  static const String initialSearchTerm = 'cheese';
  static const Duration searchDebounce = Duration(milliseconds: 350);
  static const int _centsPerDollar = 100;
  static final RegExp _leadingNumber = RegExp(r'^#\d+\s*');
  static final RegExp _primaryImage = RegExp(r'_1\.webp$');

  final ClientService _client;
  final QueryService _queries;
  final StoresService _stores;

  final quantities = signal<Map<String, int>>(const {});
  late final totalCount = computed(
    () => quantities.value.values.fold(0, (sum, count) => sum + count),
  );

  final products = signal<List<ProductItem>>(const []);
  final loading = signal(false);
  final error = signal<Object?>(null);
  final hasMore = signal(true);
  final total = signal<int?>(null);

  final selectedCategoryIds = signal<Set<int>>(const {});
  final sort = signal(ProductSort.relevance);
  final viewMode = signal(ProductView.list);

  late final LazyQuery<ProductCategoriesResponse?> _categoriesQuery = _queries
      .useGetProductCategories();
  late final categories = computed(
    () => _categoriesQuery.$data.value?.categories ?? const <ProductCategory>[],
  );
  late final activeFilterCount = computed(
    () =>
        selectedCategoryIds.value.length +
        (sort.value == ProductSort.relevance ? 0 : 1),
  );

  Future<void> loadCategories() async {
    await _categoriesQuery.trigger();
  }

  void toggleCategory(int id) {
    final current = selectedCategoryIds.value;
    selectedCategoryIds.value = current.contains(id)
        ? ({...current}..remove(id))
        : {...current, id};
  }

  void setCategories(Iterable<int> ids, {required bool on}) {
    final current = {...selectedCategoryIds.value};
    on ? current.addAll(ids) : current.removeAll(ids);
    selectedCategoryIds.value = current;
  }

  void setSort(ProductSort value) => sort.value = value;

  void resetFilters() {
    selectedCategoryIds.value = const {};
    sort.value = ProductSort.relevance;
  }

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

  late final void Function() _disposeSelection;
  bool _selectionSeen = false;
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
    _debounce?.cancel();
    final next = term.trim();
    if (next.isEmpty || next == _searchTerm) return Future.value();
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
    total.value = null;
    return loadMore(force: force);
  }

  Future<void> loadMore({bool force = false}) async {
    if (_disposed || loading.value || !hasMore.value) return;
    final generation = _generation;
    loading.value = true;
    error.value = null;
    if (!await _stores.ensureLoaded()) {
      if (!_disposed && generation == _generation) {
        error.value = _stores.error.value ?? StateError('No stores');
        loading.value = false;
      }
      return;
    }
    if (_disposed || generation != _generation) return;
    final selected = _stores.applied.value;
    // TODO: send selectedCategoryIds and sort once the products API accepts them
    final query = _queries.useGetProducts(
      searchTerm: _searchTerm,
      skip: _skip,
      limit: pageSize,
      storeIds: [for (final store in selected) store.id],
    );
    try {
      final page = await query.trigger(force: force);
      if (_disposed || generation != _generation) return;
      if (page == null) {
        final failure = query.$error.value;
        if (failure != null) error.value = failure;
        return;
      }
      total.value = page.total;
      final received = page.products;
      products.value = [
        ...products.value,
        for (final product in received) ?_toItem(product, selected),
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

  ProductItem? _toItem(ProductSummary product, List<StoreLocation> selected) {
    final priced = <StorePrice>[];
    final unavailable = <StorePrice>[];
    for (final store in selected) {
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
    _disposeSelection();
    _debounce?.cancel();
    _generation++;
    totalCount.dispose();
    activeFilterCount.dispose();
    categories.dispose();
    _categoriesQuery.dispose();
    total.dispose();
    selectedCategoryIds.dispose();
    sort.dispose();
    viewMode.dispose();
    quantities.dispose();
    products.dispose();
    loading.dispose();
    error.dispose();
    hasMore.dispose();
  }
}

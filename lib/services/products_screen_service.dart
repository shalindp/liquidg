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
      if (_stores.ready.value) _reset();
    });
  }

  static const int pageSize = 8;
  static const int maxQuantity = 99;
  static const String initialSearchTerm = '';
  static const Duration searchDebounce = Duration(milliseconds: 350);
  static const Duration categoryDebounce = Duration(milliseconds: 300);
  static const int _centsPerDollar = 100;
  static final RegExp _barcodePattern = RegExp(r'^\d{8,14}$');
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

  final selectedCategoryPaths = signal<Set<String>>(const {});
  final quickCategory = signal<String?>(null);
  final sort = signal(ProductSort.relevance);
  final viewMode = signal(ProductView.list);

  late final LazyQuery<ProductCategoriesResponse?> _categoriesQuery = _queries
      .useGetProductCategories();
  late final categoriesLoading = computed(
    () =>
        _categoriesQuery.$data.value == null &&
        _categoriesQuery.$error.value == null,
  );
  late final categories = computed(
    () => _categoriesQuery.$data.value?.categories ?? const <ProductCategory>[],
  );
  late final activeFilterCount = computed(
    () =>
        selectedCategoryPaths.value.length +
        (quickCategory.value == null ? 0 : 1) +
        (sort.value == ProductSort.relevance ? 0 : 1),
  );

  Future<void> loadCategories() async {
    await _categoriesQuery.trigger();
  }

  void toggleCategory(String id) {
    final current = selectedCategoryPaths.value;
    _applyCategories(
      current.contains(id) ? ({...current}..remove(id)) : {...current, id},
    );
  }

  void selectQuickCategory(String path) {
    final next = quickCategory.value == path ? null : path;
    _applyCategories(const {}, quick: next);
  }

  void setCategories(Iterable<String> ids, {required bool on}) {
    final current = {...selectedCategoryPaths.value};
    on ? current.addAll(ids) : current.removeAll(ids);
    _applyCategories(current);
  }

  void _applyCategories(Set<String> next, {String? quick}) {
    selectedCategoryPaths.value = next;
    quickCategory.value = quick;
    _categoryTimer?.cancel();
    _categoryTimer = Timer(categoryDebounce, () {
      if (!_disposed) _reset();
    });
  }

  void setSort(ProductSort value) => sort.value = value;

  void resetFilters() {
    sort.value = ProductSort.relevance;
    if (selectedCategoryPaths.value.isNotEmpty || quickCategory.value != null) {
      _applyCategories(const {});
    }
  }

  final basketItems = signal<Map<String, ProductItem>>(const {});

  int quantityOf(String productId) => quantities.value[productId] ?? 0;

  void setQuantity(ProductItem item, int quantity) {
    final next = quantity.clamp(0, maxQuantity);
    final updated = {...quantities.value};
    final items = {...basketItems.value};
    if (next == 0) {
      updated.remove(item.id);
      items.remove(item.id);
    } else {
      updated[item.id] = next;
      items[item.id] = item;
    }
    quantities.value = updated;
    basketItems.value = items;
  }

  void clearBasket() {
    quantities.value = const {};
    basketItems.value = const {};
  }

  late final void Function() _disposeSelection;
  Timer? _debounce;
  Timer? _categoryTimer;
  final _termSignal = signal(initialSearchTerm);
  final _barcodeSignal = signal<String?>(null);
  final _typedCategorySignal = signal<String?>(null);

  String get _searchTerm => _termSignal.value;
  set _searchTerm(String value) => _termSignal.value = value;
  String? get _barcode => _barcodeSignal.value;
  set _barcode(String? value) => _barcodeSignal.value = value;
  String? get _typedCategory => _typedCategorySignal.value;
  set _typedCategory(String? value) => _typedCategorySignal.value = value;

  late final showingFeatured = computed(
    () =>
        _termSignal.value.isEmpty &&
        _barcodeSignal.value == null &&
        _typedCategorySignal.value == null &&
        selectedCategoryPaths.value.isEmpty &&
        quickCategory.value == null,
  );
  int _skip = 0;
  int _generation = 0;
  bool _disposed = false;

  String get searchTerm => _searchTerm;
  String? get barcode => _barcode;

  void onSearchChanged(String term) {
    _debounce?.cancel();
    if (term.trim().isEmpty) {
      search(term);
      return;
    }
    _debounce = Timer(searchDebounce, () => search(term));
  }

  Future<void> search(String term) {
    _debounce?.cancel();
    final next = term.trim();
    if (_barcodePattern.hasMatch(next)) return searchBarcode(next);
    final category = _matchCategory(next);
    if (category != null) {
      if (category == _typedCategory &&
          _searchTerm.isEmpty &&
          _barcode == null) {
        return Future.value();
      }
      _searchTerm = '';
      _barcode = null;
      _typedCategory = category;
      return _reset();
    }
    if (next == _searchTerm && _barcode == null && _typedCategory == null) {
      return Future.value();
    }
    _searchTerm = next;
    _barcode = null;
    _typedCategory = null;
    return _reset();
  }

  Future<void> searchBarcode(String code) {
    _debounce?.cancel();
    final next = code.trim();
    if (next.isEmpty || _barcode == next) return Future.value();
    _searchTerm = '';
    _typedCategory = null;
    _barcode = next;
    return _reset();
  }

  List<String> _categoryFilter() {
    final typed = _typedCategory;
    final selected = {
      ...selectedCategoryPaths.value,
      ?quickCategory.value,
      ?typed,
    };
    return selected.toList();
  }

  String? _matchCategory(String text) {
    final key = _categoryKey(text);
    if (key.isEmpty) return null;
    String? walk(List<ProductCategory> nodes) {
      for (final node in nodes) {
        if (_categoryKey(node.path) == key || _categoryKey(node.name) == key) {
          return node.path;
        }
        final found = walk(node.children);
        if (found != null) return found;
      }
      return null;
    }

    return walk(categories.value);
  }

  String _categoryKey(String text) =>
      text.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

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
    // TODO: send sort once the products API accepts it
    final barcode = _barcode;
    final categoryFilter = _categoryFilter();
    final featured = showingFeatured.value;
    final storeIds = [for (final store in selected) store.id];
    var added = 0;
    try {
      while (added < pageSize && hasMore.value) {
        final query = featured
            ? _queries.useGetFeaturedProducts(
                skip: _skip,
                limit: pageSize,
                storeIds: storeIds,
              )
            : _queries.useGetProducts(
                searchTerm: barcode == null ? _searchTerm : '',
                barcode: barcode,
                categories: categoryFilter,
                skip: _skip,
                limit: pageSize,
                storeIds: storeIds,
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
          final items = [
            for (final product in received) ?_toItem(product, selected),
          ];
          added += items.length;
          products.value = [...products.value, ...items];
          _skip = page.skip + received.length;
          hasMore.value = received.isNotEmpty && _skip < page.total;
        } finally {
          query.dispose();
        }
      }
    } catch (failure) {
      if (!_disposed && generation == _generation) error.value = failure;
    } finally {
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
    priced.sort((a, b) => a.price!.compareTo(b.price!));
    final stores = [...priced, ...unavailable];
    return ProductItem(
      id: product.productId,
      name: product.name.replaceFirst(_leadingNumber, ''),
      packSize: product.packSize,
      category: _category(product),
      imageUrl: _imageUrl(product),
      stores: stores,
    );
  }

  String _category(ProductSummary product) {
    if (product.categories.isEmpty) return 'Other';
    final top = product.categories.first.split('>').first.trim();
    return top.isEmpty ? 'Other' : top;
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
    _categoryTimer?.cancel();
    _generation++;
    totalCount.dispose();
    activeFilterCount.dispose();
    categories.dispose();
    categoriesLoading.dispose();
    _categoriesQuery.dispose();
    total.dispose();
    selectedCategoryPaths.dispose();
    quickCategory.dispose();
    showingFeatured.dispose();
    _termSignal.dispose();
    _barcodeSignal.dispose();
    _typedCategorySignal.dispose();
    sort.dispose();
    viewMode.dispose();
    quantities.dispose();
    basketItems.dispose();
    products.dispose();
    loading.dispose();
    error.dispose();
    hasMore.dispose();
  }
}

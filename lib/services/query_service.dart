import 'package:ominicart_api/ominicart_api.dart';

import '../query/query.dart';
import 'client_service.dart';

class QueryService {
  QueryService(this._client, this._query);

  static const String productsKey = 'products/list';
  static const String storesKey = 'stores';
  static const String categoriesKey = 'products/categories';

  final ClientService _client;
  final Query _query;

  LazyQuery<ProductsResponse?> useGetProducts({
    required String searchTerm,
    required int skip,
    required int limit,
    required List<int> storeIds,
    String? barcode,
    List<String> categories = const [],
  }) {
    return _query.useLazyQuery(
      '$productsKey/$searchTerm/${barcode ?? ''}/${categories.join('|')}/$skip/$limit/${storeIds.join(',')}',
      () async {
        final response = await _client.api.getProductsApi().getProducts(
          getProductsRequest: GetProductsRequest(
            searchTerm: searchTerm,
            skip: skip,
            limit: limit,
            retailerRegionIds: storeIds,
            barcode: barcode,
            categories: categories.isEmpty ? null : categories,
          ),
        );
        return response.data;
      },
    );
  }

  LazyQuery<ProductCategoriesResponse?> useGetProductCategories() {
    return _query.useLazyQuery(categoriesKey, () async {
      final response = await _client.api
          .getProductsApi()
          .getProductCategories();
      return response.data;
    });
  }

  LazyQuery<List<Store>> useGetStores() {
    return _query.useLazyQuery(storesKey, () async {
      final response = await _client.api.getStoresApi().getStores();
      return response.data ?? const [];
    });
  }

  Mutation<SetUserStoresResponse?, List<int>> useSetUserStores() {
    return _query.useMutation((List<int> storeIds) async {
      final response = await _client.api.getStoresApi().setUserStores(
        requestBody: storeIds,
      );
      return response.data;
    }, invalidates: [productsKey]);
  }

  Mutation<AuthResponse?, LoginRequest> useLogin() {
    return _query.useMutation((LoginRequest request) async {
      final response = await _client.api.getAuthApi().login(
        loginRequest: request,
      );
      return response.data;
    });
  }

  void dispose() => _query.dispose();
}

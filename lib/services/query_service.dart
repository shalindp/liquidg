import 'package:ominicart_api/ominicart_api.dart';

import '../query/query.dart';
import 'client_service.dart';

class QueryService {
  QueryService(this._client, this._query);

  static const String productsKey = 'products/list';
  static const String categoriesKey = 'products/categories';

  final ClientService _client;
  final Query _query;

  LazyQuery<ProductsResponse?> useGetProducts({
    required String searchTerm,
    required int skip,
    required int limit,
    required List<int> storeIds,
  }) {
    return _query.useLazyQuery(
      '$productsKey/$searchTerm/$skip/$limit/${storeIds.join(',')}',
      () async {
        final response = await _client.api.getProductsApi().getProducts(
          getProductsRequest: GetProductsRequest(
            searchTerm: searchTerm,
            skip: skip,
            limit: limit,
            retailerRegionIds: storeIds,
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

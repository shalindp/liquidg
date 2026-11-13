import 'package:ominicart_api/ominicart_api.dart';

import '../query/query.dart';
import 'client_service.dart';

class QueryService {
  QueryService(this._client, this._query);

  static const String productsKey = 'products/list';
  static const String storesKey = 'stores';
  static const String selectedStoresKey = 'stores/selected';
  static const String categoriesKey = 'products/categories';
  static const String basketKey = 'basket';
  static const String listsKey = 'lists';

  final ClientService _client;
  final Query _query;

  LazyQuery<ProductsResponse?> useGetProducts({
    required String searchTerm,
    required int skip,
    required int limit,
    required List<int> storeIds,
    String? barcode,
    List<String> categories = const [],
    bool showFavourites = false,
  }) {
    return _query.useLazyQuery(
      '$productsKey/$searchTerm/${barcode ?? ''}/${categories.join('|')}/${showFavourites ? 'fav' : 'all'}/$skip/$limit/${storeIds.join(',')}',
      () async {
        final response = await _client.api.getProductsApi().getProducts(
          getProductsRequest: GetProductsRequest(
            searchTerm: searchTerm,
            skip: skip,
            limit: limit,
            retailerRegionIds: storeIds,
            barcode: barcode,
            categories: categories.isEmpty ? null : categories,
            showFavourites: showFavourites ? true : null,
          ),
        );
        return response.data;
      },
    );
  }

  LazyQuery<Basket?> useGetBasket() {
    return _query.useLazyQuery(basketKey, () async {
      final response = await _client.api.getBasketApi().getBasket();
      return response.data;
    });
  }

  Mutation<Basket?, List<ProductQuantityRequest>> useSetBasket() {
    return _query.useMutation((List<ProductQuantityRequest> items) async {
      final response = await _client.api.getBasketApi().setBasket(
        setBasketRequest: SetBasketRequest(items: items),
      );
      return response.data;
    });
  }

  Mutation<ShoppingList?, ({String name, List<int> storeIds})>
  useCreateListFromBasket() {
    return _query.useMutation((({String name, List<int> storeIds}) args) async {
      final response = await _client.api.getListsApi().createListFromBasket(
        createListFromBasketRequest: CreateListFromBasketRequest(
          name: args.name,
          storeIds: args.storeIds,
        ),
      );
      return response.data;
    }, invalidates: [listsKey]);
  }

  LazyQuery<ListsResponse?> useGetLists() {
    return _query.useLazyQuery(listsKey, () async {
      final response = await _client.api.getListsApi().getLists();
      return response.data;
    });
  }

  LazyQuery<ListView?> useGetList(int listId) {
    return _query.useLazyQuery('$listsKey/$listId', () async {
      final response = await _client.api.getListsApi().getList(listId: listId);
      return response.data;
    });
  }

  Mutation<void, int> useDeleteList() {
    return _query.useMutation((int listId) async {
      await _client.api.getListsApi().deleteList(listId: listId);
    }, invalidates: [listsKey]);
  }

  Mutation<FavouritesResponse?, List<String>> useSetFavourites() {
    return _query.useMutation((List<String> productIds) async {
      final response = await _client.api.getFavouritesApi().setUserFavourites(
        setUserFavouritesRequest: SetUserFavouritesRequest(
          productIds: productIds,
        ),
      );
      return response.data;
    });
  }

  LazyQuery<ProductsResponse?> useGetFeaturedProducts({
    required int skip,
    required int limit,
    required List<int> storeIds,
  }) {
    return _query.useLazyQuery(
      '$productsKey/featured/$skip/$limit/${storeIds.join(',')}',
      () async {
        final response = await _client.api.getProductsApi().getFeaturedProducts(
          getFeaturedProductsRequest: GetFeaturedProductsRequest(
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

  LazyQuery<List<Store>> useGetStores() {
    return _query.useLazyQuery(storesKey, () async {
      final response = await _client.api.getStoresApi().getStores();
      return response.data ?? const [];
    });
  }

  LazyQuery<List<Store>> useGetSelectedStores() {
    return _query.useLazyQuery(selectedStoresKey, () async {
      final response = await _client.api.getStoresApi().getSelectedStores();
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

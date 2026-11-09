# TODO

- Products API: accept category IDs, sort order and offer flags (specials, multibuy, member price) in `GetProductsRequest`, regenerate the Dart client, then send `selectedCategoryIds` and `sort` from `ProductsScreenService.loadMore`. Until then the filter chips and the filters tray only hold state; results are not filtered or sorted.
- Products tray: Allergens, Dietary and Lifestyle, Bought before, Unit Price sort and the grid view are shown disabled until data or UI exists.

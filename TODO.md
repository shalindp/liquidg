# TODO

- Products API: accept sort order and offer flags (specials, multibuy, member price) in `GetProductsRequest`, regenerate the Dart client, then send `sort` from `ProductsScreenService.loadMore`. Until then the sort option and the offer filters only hold state. Categories and barcode are already sent.
- Products tray: Allergens, Dietary and Lifestyle, Bought before, Unit Price sort and the grid view are shown disabled until data or UI exists.
- Dark mode: `ThemeController` defaults to `ThemeMode.light` so the app ignores the system setting. Fix the dark theme, then switch the default back to `ThemeMode.system` in `lib/theme/app_theme.dart` and update rule 6 in `CLAUDE.md`.

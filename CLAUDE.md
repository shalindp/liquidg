# Project rules

1. No code comments (`//`, `///`, `/* */`) unless the user explicitly asks for them. This includes doc comments and generated-file headers.
2. Every file in `lib/screens/` is a screen and its name ends with `_screen.dart`.
3. All theme code lives in `lib/theme/`. Import it through `lib/theme/theme.dart`.
4. Colour, spacing and radius tokens come from Tailwind: `TwColors`, `TwSpacing`, `TwRadius`. Do not hard-code hex colours or magic numbers where a token exists.
5. Colours that must follow light/dark mode come from `context.colors` (`AppColors`) or the Mix colour tokens (`$background`, `$accent`, ...). Raw `TwColors` values are static and do not switch with the mode.
6. Theme mode defaults to `ThemeMode.system`. `themeController` in `lib/main.dart` overrides it.
7. Style widgets with Mix (`BoxStyler`, `TextStyler`, tokens from `lib/theme/mix_tokens.dart`) where it fits.
8. Navigation uses `go_router`, configured in `lib/router.dart`. Tabs are a `StatefulShellRoute.indexedStack` so each tab keeps its state. Tabs: stores, products, lists, more. `more` has the sub route `features`.
9. The glass UI (scaffold, app bar, tab bar) uses `liquid_glass_easy`. `LiquidGlassEngine.liteGlassOnSkia` is on so non-Impeller devices get the cheap glass.
10. Icons come from `phosphoricons_flutter` (`PhosphorIconsRegular.*`, `PhosphorIconsFill.*`). Do not use `phosphor_flutter` (fails to build: it extends the final `IconData`) or `hugeicons` (stroke-only, removed).
11. Active tab icons use the Fill style, inactive use Regular.
12. Run `flutter analyze` after changes and fix everything it reports.
13. `make dark`, `make light` and `make auto-theme` switch the Android emulator colour mode through adb.

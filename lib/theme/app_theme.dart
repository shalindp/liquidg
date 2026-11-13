import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static final ButtonStyle _noFeedback = ButtonStyle(
    overlayColor: const WidgetStatePropertyAll(Colors.transparent),
    splashFactory: NoSplash.splashFactory,
  );

  static ThemeData get light => _build(Brightness.light, AppColors.light);
  static ThemeData get dark => _build(Brightness.dark, AppColors.dark);

  static ThemeData _build(Brightness brightness, AppColors c) {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: c.accent,
          brightness: brightness,
        ).copyWith(
          primary: c.accent,
          onPrimary: c.textOnAccent,
          surface: c.surface,
          onSurface: c.textPrimary,
          error: c.danger,
          outline: c.border,
        );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.background,
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      filledButtonTheme: FilledButtonThemeData(style: _noFeedback),
      textButtonTheme: TextButtonThemeData(style: _noFeedback),
      outlinedButtonTheme: OutlinedButtonThemeData(style: _noFeedback),
      elevatedButtonTheme: ElevatedButtonThemeData(style: _noFeedback),
      iconButtonTheme: IconButtonThemeData(style: _noFeedback),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.background,
        modalBackgroundColor: c.background,
        surfaceTintColor: Colors.transparent,
      ),
      extensions: [c],
    );
  }
}

class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController([super.value = ThemeMode.light]);
}

extension AppThemeContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}

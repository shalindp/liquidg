import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Material themes built from [AppColors].
abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light, AppColors.light);
  static ThemeData get dark => _build(Brightness.dark, AppColors.dark);

  static ThemeData _build(Brightness brightness, AppColors c) {
    final scheme = ColorScheme.fromSeed(
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
      extensions: [c],
    );
  }
}

/// Holds the user's theme choice. Defaults to following the system.
class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController([super.value = ThemeMode.system]);
}

extension AppThemeContext on BuildContext {
  /// Semantic colours for the current brightness.
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}

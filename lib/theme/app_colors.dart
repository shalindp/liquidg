import 'package:flutter/material.dart';

import 'tailwind_colors.dart';

/// Semantic colours, resolved per brightness from the Tailwind palette.
/// Reach them with `context.colors` (see theme.dart).
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textOnAccent,
    required this.accent,
    required this.accentPressed,
    required this.danger,
    required this.success,
    required this.warning,
  });

  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textOnAccent;
  final Color accent;
  final Color accentPressed;
  final Color danger;
  final Color success;
  final Color warning;

  static final AppColors light = AppColors(
    background: TwColors.zinc.s100,
    surface: TwColors.white,
    surfaceMuted: TwColors.zinc.s200,
    border: TwColors.zinc.s200,
    textPrimary: TwColors.zinc.s900,
    textSecondary: TwColors.zinc.s500,
    textOnAccent: TwColors.white,
    accent: TwColors.blue.s500,
    accentPressed: TwColors.blue.s600,
    danger: TwColors.red.s500,
    success: TwColors.green.s500,
    warning: TwColors.amber.s500,
  );

  static final AppColors dark = AppColors(
    background: TwColors.zinc.s950,
    surface: TwColors.zinc.s900,
    surfaceMuted: TwColors.zinc.s800,
    border: TwColors.zinc.s800,
    textPrimary: TwColors.zinc.s50,
    textSecondary: TwColors.zinc.s400,
    textOnAccent: TwColors.white,
    accent: TwColors.blue.s400,
    accentPressed: TwColors.blue.s500,
    danger: TwColors.red.s400,
    success: TwColors.green.s400,
    warning: TwColors.amber.s400,
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceMuted,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textOnAccent,
    Color? accent,
    Color? accentPressed,
    Color? danger,
    Color? success,
    Color? warning,
  }) =>
      AppColors(
        background: background ?? this.background,
        surface: surface ?? this.surface,
        surfaceMuted: surfaceMuted ?? this.surfaceMuted,
        border: border ?? this.border,
        textPrimary: textPrimary ?? this.textPrimary,
        textSecondary: textSecondary ?? this.textSecondary,
        textOnAccent: textOnAccent ?? this.textOnAccent,
        accent: accent ?? this.accent,
        accentPressed: accentPressed ?? this.accentPressed,
        danger: danger ?? this.danger,
        success: success ?? this.success,
        warning: warning ?? this.warning,
      );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      background: l(background, other.background),
      surface: l(surface, other.surface),
      surfaceMuted: l(surfaceMuted, other.surfaceMuted),
      border: l(border, other.border),
      textPrimary: l(textPrimary, other.textPrimary),
      textSecondary: l(textSecondary, other.textSecondary),
      textOnAccent: l(textOnAccent, other.textOnAccent),
      accent: l(accent, other.accent),
      accentPressed: l(accentPressed, other.accentPressed),
      danger: l(danger, other.danger),
      success: l(success, other.success),
      warning: l(warning, other.warning),
    );
  }
}

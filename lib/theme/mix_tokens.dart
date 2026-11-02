import 'package:flutter/material.dart';
import 'package:mix/mix.dart';

import 'app_colors.dart';
import 'tailwind_radius.dart';
import 'tailwind_spacing.dart';

const $background = ColorToken('color.background');
const $surface = ColorToken('color.surface');
const $surfaceMuted = ColorToken('color.surfaceMuted');
const $border = ColorToken('color.border');
const $textPrimary = ColorToken('color.textPrimary');
const $textSecondary = ColorToken('color.textSecondary');
const $textOnAccent = ColorToken('color.textOnAccent');
const $accent = ColorToken('color.accent');
const $accentPressed = ColorToken('color.accentPressed');
const $danger = ColorToken('color.danger');
const $success = ColorToken('color.success');
const $warning = ColorToken('color.warning');

const $space1 = SpaceToken('space.1');
const $space2 = SpaceToken('space.2');
const $space3 = SpaceToken('space.3');
const $space4 = SpaceToken('space.4');
const $space5 = SpaceToken('space.5');
const $space6 = SpaceToken('space.6');
const $space8 = SpaceToken('space.8');
const $space10 = SpaceToken('space.10');
const $space12 = SpaceToken('space.12');
const $space16 = SpaceToken('space.16');

const $radiusSm = RadiusToken('radius.sm');
const $radiusMd = RadiusToken('radius.md');
const $radiusLg = RadiusToken('radius.lg');
const $radiusXl = RadiusToken('radius.xl');
const $radius2xl = RadiusToken('radius.2xl');
const $radius3xl = RadiusToken('radius.3xl');
const $radiusFull = RadiusToken('radius.full');

class AppMixScope extends StatelessWidget {
  const AppMixScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c =
        Theme.of(context).extension<AppColors>() ??
        (Theme.brightnessOf(context) == Brightness.dark
            ? AppColors.dark
            : AppColors.light);
    return MixScope(
      colors: {
        $background: c.background,
        $surface: c.surface,
        $surfaceMuted: c.surfaceMuted,
        $border: c.border,
        $textPrimary: c.textPrimary,
        $textSecondary: c.textSecondary,
        $textOnAccent: c.textOnAccent,
        $accent: c.accent,
        $accentPressed: c.accentPressed,
        $danger: c.danger,
        $success: c.success,
        $warning: c.warning,
      },
      spaces: {
        $space1: TwSpacing.s1,
        $space2: TwSpacing.s2,
        $space3: TwSpacing.s3,
        $space4: TwSpacing.s4,
        $space5: TwSpacing.s5,
        $space6: TwSpacing.s6,
        $space8: TwSpacing.s8,
        $space10: TwSpacing.s10,
        $space12: TwSpacing.s12,
        $space16: TwSpacing.s16,
      },
      radii: {
        $radiusSm: const Radius.circular(TwRadius.sm),
        $radiusMd: const Radius.circular(TwRadius.md),
        $radiusLg: const Radius.circular(TwRadius.lg),
        $radiusXl: const Radius.circular(TwRadius.xl),
        $radius2xl: const Radius.circular(TwRadius.xl2),
        $radius3xl: const Radius.circular(TwRadius.xl3),
        $radiusFull: const Radius.circular(TwRadius.full),
      },
      child: child,
    );
  }
}

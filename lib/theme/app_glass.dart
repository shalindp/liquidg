import 'package:flutter/material.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';

import 'tailwind_colors.dart';

abstract final class AppGlass {
  static LiquidGlassLight specular(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    return LiquidGlassLight.specular(
      thickness: 2,
      sharpness: 0.9,
      angle: 0,
      spread: 0.55,
      intensity: 1,
      oppositeIntensity: 1,
      color: dark
          ? TwColors.white.withValues(alpha: 0.5)
          : TwColors.black.withValues(alpha: 0.38),
    );
  }

  static LiquidGlassStyle style(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    return LiquidGlassStyle(
      color: dark
          ? TwColors.white.withValues(alpha: 0.06)
          : TwColors.black.withValues(alpha: 0.04),
      blur: 0,
      refractionIndex: 1.02,
      refractionWidth: 24,
      specular: specular(brightness),
      glow: LiquidGlassLight.glow(
        thickness: 3,
        angle: 90,
        spread: 0.5,
        intensity: 2.2,
        oppositeIntensity: 0,
        color: TwColors.green.s200.withValues(alpha: 0.9),
      ),
      shadow: const LiquidGlassShadow(blur: 6, opacity: 0.05),
    );
  }
}

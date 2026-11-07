import 'package:flutter/material.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';

import '../theme/theme.dart';

class AppGlassButton extends StatelessWidget {
  const AppGlassButton({
    super.key,
    required this.child,
    this.onPressed,
    this.size = TwSpacing.s11,
    this.visible = true,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final double size;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassButton(
      width: size,
      height: size,
      visibility: visible,
      padding: EdgeInsets.zero,
      style: AppGlass.style(Theme.brightnessOf(context)),
      touch: const LiquidGlassTouch(
        flex: LiquidGlassFlex(
          stretch: 4,
          maxPull: 24,
          lean: 0.3,
          holdScale: 0.107,
          tapScale: 0.16,
          advanced: LiquidGlassFlexAdvanced(releaseDamping: 12),
        ),
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}

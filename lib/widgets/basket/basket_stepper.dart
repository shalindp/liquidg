import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../theme/theme.dart';

class BasketStepper extends StatelessWidget {
  const BasketStepper({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.canDecrement = true,
    this.canIncrement = true,
  });

  static const double height = TwSpacing.s9;
  static const double _valueWidth = TwSpacing.s11;

  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool canDecrement;
  final bool canIncrement;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepButton(
          icon: HugeIcons.strokeRoundedMinusSign,
          enabled: canDecrement,
          onTap: onDecrement,
        ),
        Text(
              '$quantity',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: TwFontSize.base,
                fontWeight: TwFontWeight.medium,
              ),
            )
            .center()
            .constrained(width: _valueWidth, height: height)
            .backgroundColor(colors.surfaceMuted),
        _StepButton(
          icon: HugeIcons.strokeRoundedAdd01,
          enabled: canIncrement,
          onTap: onIncrement,
        ),
      ],
    ).clipRRect(all: TwRadius.lg);
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final List<List<dynamic>> icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return HugeIcon(
          icon: icon,
          color: enabled
              ? colors.textOnAccent
              : colors.textOnAccent.withValues(alpha: 0.8),
          size: TwSpacing.s5,
        )
        .center()
        .constrained(width: BasketStepper.height, height: BasketStepper.height)
        .backgroundColor(
          enabled
              ? BrandColors.accent500
              : colors.textSecondary.withValues(alpha: 0.35),
        )
        .gestures(
          behavior: HitTestBehavior.opaque,
          onTap: enabled
              ? () {
                  HapticFeedback.selectionClick();
                  onTap();
                }
              : null,
        );
  }
}

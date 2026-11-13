import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:styled_widget/styled_widget.dart';

import '../theme/theme.dart';

class NoPermsView extends StatelessWidget {
  const NoPermsView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  }) : assert(
         (secondaryLabel == null) == (onSecondary == null),
         'secondaryLabel and onSecondary must be set together',
       );

  final List<List<dynamic>> icon;
  final String title;
  final String message;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: TwSpacing.s4,
      children: [
        HugeIcon(
          icon: icon,
          color: colors.textSecondary,
          size: TwSpacing.s14,
        ).center(),
        Column(
          spacing: TwSpacing.s2,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: TwFontSize.lg,
                fontWeight: TwFontWeight.semibold,
              ),
            ),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: TwFontSize.sm,
              ),
            ),
          ],
        ),
        FilledButton(
          onPressed: onPrimary,
          style: FilledButton.styleFrom(
            overlayColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory,
            backgroundColor: BrandColors.accent500,
            foregroundColor: colors.textOnAccent,
            minimumSize: const Size.fromHeight(TwSpacing.s14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(TwRadius.xl2),
            ),
            textStyle: const TextStyle(
              fontSize: TwFontSize.base,
              fontWeight: TwFontWeight.semibold,
            ),
          ),
          child: Text(primaryLabel),
        ),
        if (secondaryLabel != null)
          TextButton(
            onPressed: onSecondary,
            style: TextButton.styleFrom(
              overlayColor: Colors.transparent,
              splashFactory: NoSplash.splashFactory,
              foregroundColor: colors.textSecondary,
              minimumSize: const Size.fromHeight(TwSpacing.s11),
              textStyle: const TextStyle(
                fontSize: TwFontSize.sm,
                fontWeight: TwFontWeight.medium,
              ),
            ),
            child: Text(secondaryLabel!),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../services/basket_screen_service.dart';
import '../../theme/theme.dart';

class BasketFooter extends StatelessWidget {
  const BasketFooter({super.key, required this.service});

  static const double _hairline = 0.5;

  final BasketScreenService service;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final total = service.total.value;
    final savings = service.savings.value;
    final stores = service.storeCount.value;
    return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: TwSpacing.s2,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  'Estimated total',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: TwFontSize.lg,
                    fontWeight: TwFontWeight.medium,
                  ),
                ).expanded(),
                Text(
                  total.label,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: TwFontSize.xl,
                    fontWeight: TwFontWeight.bold,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  'Based on your $stores ${stores == 1 ? 'store' : 'stores'}',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: TwFontSize.xs,
                  ),
                ).expanded(),
                if (savings >= 0.01)
                  Text(
                        'SAVE UP TO \$${savings.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: TwColors.zinc.s900,
                          fontSize: TwFontSize.xs,
                          fontWeight: TwFontWeight.bold,
                        ),
                      )
                      .padding(
                        horizontal: TwSpacing.s2_5,
                        vertical: TwSpacing.s1,
                      )
                      .decorated(
                        color: TwColors.yellow.s300,
                        borderRadius: BorderRadius.circular(TwRadius.md),
                      ),
              ],
            ),
            const SizedBox(height: TwSpacing.s1),
            FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
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
              child: const Text('Checkout'),
            ),
          ],
        )
        .padding(
          left: TwSpacing.s4,
          right: TwSpacing.s4,
          top: TwSpacing.s3,
          bottom: TwSpacing.s3 + MediaQuery.viewPaddingOf(context).bottom,
        )
        .decorated(
          color: colors.background,
          border: Border(
            top: BorderSide(color: colors.border, width: _hairline),
          ),
        );
  }
}

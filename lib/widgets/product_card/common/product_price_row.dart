part of '../product_card.dart';

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.price, required this.unitPrice});

  final String price;
  final String unitPrice;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text.rich(
              TextSpan(
                text: 'Lowest ',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: TwFontSize.sm,
                ),
                children: [
                  TextSpan(
                    text: price,
                    style: TextStyle(
                      color: colors.danger,
                      fontSize: TwFontSize.base,
                      fontWeight: TwFontWeight.semibold,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              unitPrice,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: TwFontSize.xs,
              ),
            ),
          ],
        ).expanded(),
        const _AddButton(),
      ],
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton();

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () {},
      style: FilledButton.styleFrom(
        backgroundColor: BrandColors.accent500,
        foregroundColor: context.colors.textOnAccent,
        minimumSize: const Size(TwSpacing.s24, TwSpacing.s11),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(
          fontSize: TwFontSize.sm,
          fontWeight: TwFontWeight.medium,
        ),
      ),
      child: const Text('Add'),
    );
  }
}

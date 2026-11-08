part of '../product_card.dart';

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.price,
    required this.store,
    required this.unitPrice,
  });

  final ProductPrice price;
  final String store;
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
            _Price(price: price),
            Text(
              unitPrice,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: TwFontSize.xs,
              ),
            ),
            _LowestStore(name: store),
          ],
        ).padding(right: TwSpacing.s2).expanded(),
        const _AddButton(),
      ],
    );
  }
}

class _LowestStore extends StatelessWidget {
  const _LowestStore({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/icons/woolworths_logo.png',
          width: TwSpacing.s3,
          height: TwSpacing.s3,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
        ),
        const SizedBox(width: TwSpacing.s1_5),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: context.colors.textSecondary,
            fontSize: TwFontSize.xs,
            fontWeight: TwFontWeight.medium,
          ),
        ).flexible(),
      ],
    ).padding(top: TwSpacing.s0_5);
  }
}

class _Price extends StatelessWidget {
  const _Price({required this.price});

  final ProductPrice price;

  @override
  Widget build(BuildContext context) {
    final color = context.colors.price;
    final small = TextStyle(
      color: color,
      fontSize: TwFontSize.sm,
      fontWeight: TwFontWeight.bold,
      height: 1,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '\$',
          style: small.copyWith(fontSize: TwFontSize.lg),
        ).padding(top: TwSpacing.s0_5),
        Text(
          price.dollars,
          style: TextStyle(
            color: color,
            fontSize: TwFontSize.xl2,
            fontWeight: TwFontWeight.extrabold,
            height: 1,
          ),
        ).padding(horizontal: TwSpacing.s0_5),
        Text(price.cents, style: small).padding(top: TwSpacing.s1),
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

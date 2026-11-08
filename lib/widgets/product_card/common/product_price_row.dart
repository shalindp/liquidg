part of '../product_card.dart';

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.price,
    required this.chain,
    required this.store,
    required this.unitPrice,
    required this.controller,
  });

  final ProductPrice price;
  final Supermarket chain;
  final String store;
  final String unitPrice;
  final ProductCardController controller;

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
            _LowestStore(chain: chain, name: store),
          ],
        ).padding(right: TwSpacing.s2).expanded(),
        _AddButton(controller: controller),
      ],
    );
  }
}

class _LowestStore extends StatelessWidget {
  const _LowestStore({required this.chain, required this.name});

  final Supermarket chain;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SupermarketLogo(chain: chain, size: TwSpacing.s4),
        const SizedBox(width: TwSpacing.s1_5),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: TwFontSize.sm,
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
  const _AddButton({required this.controller});

  final ProductCardController controller;

  Future<void> _openSheet(BuildContext context) async {
    HapticFeedback.lightImpact();
    final quantity = await showModalBottomSheet<int>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _AddToCartSheet(controller: controller),
    );
    if (quantity != null) {
      controller.setQuantity(quantity);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SignalBuilder(
      builder: (context) {
        final count = controller.quantity.value;
        final inBasket = controller.hasQuantity.value;
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TwRadius.full),
            boxShadow: inBasket
                ? null
                : [
                    BoxShadow(
                      color: colors.textPrimary.withValues(alpha: 0.15),
                      blurRadius: TwSpacing.s2,
                    ),
                  ],
          ),
          child: FilledButton(
            onPressed: () => _openSheet(context),
            style: FilledButton.styleFrom(
              backgroundColor: inBasket
                  ? Colors.transparent
                  : BrandColors.accent500,
              foregroundColor: inBasket
                  ? BrandColors.accent500
                  : colors.textOnAccent,
              side: const BorderSide(color: BrandColors.accent500),
              minimumSize: const Size(TwSpacing.s24, TwSpacing.s11),
              padding: const EdgeInsets.symmetric(horizontal: TwSpacing.s4),
              shape: const StadiumBorder(),
              textStyle: const TextStyle(
                fontSize: TwFontSize.sm,
                fontWeight: TwFontWeight.medium,
              ),
            ),
            child: Text(inBasket ? 'In basket ($count)' : 'Add'),
          ),
        );
      },
    );
  }
}

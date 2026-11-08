part of '../product_card.dart';

class _StoreLabel extends StatelessWidget {
  const _StoreLabel({required this.store});

  final StorePrice store;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SupermarketLogo(chain: store.chain, size: TwSpacing.s4),
        const SizedBox(width: TwSpacing.s3),
        Text.rich(
          TextSpan(
            text: '${store.chain.label} ',
            style: TextStyle(
              fontSize: TwFontSize.xs,
              fontWeight: TwFontWeight.normal,
            ),
            children: [
              TextSpan(
                text: store.branch,
                style: TextStyle(
                  fontSize: TwFontSize.sm,
                  fontWeight: TwFontWeight.normal,
                ),
              ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: context.colors.textPrimary),
        ).expanded(),
      ],
    );
  }
}

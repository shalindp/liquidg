part of '../product_card.dart';

class _StoreLabel extends StatelessWidget {
  const _StoreLabel({required this.store});

  final StorePrice store;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SupermarketLogo(chain: store.chain, size: TwSpacing.s4),
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

class _SupermarketLogo extends StatelessWidget {
  const _SupermarketLogo({required this.chain, required this.size});

  final Supermarket chain;
  final double size;

  @override
  Widget build(BuildContext context) {
    final asset = chain.logoAsset;
    final inner = size * chain.logoScale;
    final logo = asset.endsWith('.svg')
        ? SvgPicture.asset(asset, width: inner, height: inner)
        : Image.asset(
            asset,
            width: inner,
            height: inner,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
          );
    return SizedBox(
      width: size,
      height: size,
      child: Center(child: logo),
    );
  }
}

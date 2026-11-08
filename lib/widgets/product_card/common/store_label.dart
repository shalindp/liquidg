part of '../product_card.dart';

class _StoreLabel extends StatelessWidget {
  const _StoreLabel({required this.store});

  final StorePrice store;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          'assets/icons/woolworths_logo.png',
          width: TwSpacing.s4,
          height: TwSpacing.s4,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
        ),
        const SizedBox(width: TwSpacing.s3),
        Text.rich(
          TextSpan(
            text: '${store.chain} ',
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

part of '../product_card.dart';

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.url});

  static const double size = 79;

  final String url;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Image.network(
      url,
      fit: BoxFit.contain,
      cacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).round(),
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : const SizedBox.shrink(),
      errorBuilder: (context, _, _) => HugeIcon(
        icon: HugeIcons.strokeRoundedImage01,
        color: colors.textSecondary,
        size: TwSpacing.s8,
      ).center(),
    );
  }
}

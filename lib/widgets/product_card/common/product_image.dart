part of '../product_card.dart';

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.url});

  static const double size = 72;

  final String? url;

  @override
  Widget build(BuildContext context) {
    final url = this.url;
    if (url == null) return const _ImagePlaceholder();
    return Image.network(
      url,
      fit: BoxFit.contain,
      cacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).round(),
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : const SizedBox.shrink(),
      errorBuilder: (context, _, _) => const _ImagePlaceholder(),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return HugeIcon(
      icon: HugeIcons.strokeRoundedImage01,
      color: context.colors.textSecondary,
      size: TwSpacing.s8,
    ).center();
  }
}

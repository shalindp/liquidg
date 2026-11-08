part of '../product_card.dart';

class _AddToCartSheet extends StatefulWidget {
  const _AddToCartSheet({required this.controller});

  final ProductCardController controller;

  @override
  State<_AddToCartSheet> createState() => _AddToCartSheetState();
}

class _AddToCartSheetState extends State<_AddToCartSheet> {
  static const int _visibleItems = 5;
  static const double _tickHeight = 10;
  static const double _tickWidth = 1.5;
  static const double _fadeWidth = 72;
  static const double _fadeMidAlpha = 0.5;
  static const double _fadeMidStop = 0.4;

  late final int _initial = widget.controller.quantity.value;
  late final selected = signal(math.max(1, _initial));

  @override
  void dispose() {
    selected.dispose();
    super.dispose();
  }

  void _selectAt(double dx, double itemWidth) {
    final offset = (dx / itemWidth).floor() - _visibleItems ~/ 2;
    selected.value = (selected.value + offset).clamp(
      1,
      ProductsScreenService.maxQuantity,
    );
  }

  Widget _fade(Color color, Alignment begin, Alignment end) {
    return IgnorePointer(
      child: const SizedBox(width: _fadeWidth).decorated(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: [
            color,
            color.withValues(alpha: _fadeMidAlpha),
            color.withValues(alpha: 0),
          ],
          stops: const [0, _fadeMidStop, 1],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final c = widget.controller;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return SignalBuilder(
      builder: (context) {
        final quantity = selected.value;
        final hasExisting = _initial > 0;
        final changed = !hasExisting || quantity != _initial;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: TwSpacing.s4,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: TwSpacing.s4,
              children: [
                _ProductImage(url: c.imageUrl).constrained(
                  width: _ProductImage.size,
                  height: _ProductImage.size,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: TwSpacing.s1,
                  children: [
                    Text(
                      c.name,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: TwFontSize.base,
                        fontWeight: TwFontWeight.medium,
                      ),
                    ),
                    Text(
                      c.lowestStore.label,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: TwFontSize.xl2,
                        fontWeight: TwFontWeight.semibold,
                      ),
                    ),
                    Text(
                      c.unitPrice,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: TwFontSize.xs,
                        fontWeight: TwFontWeight.medium,
                      ),
                    ),
                  ],
                ).expanded(),
              ],
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = constraints.maxWidth / _visibleItems;
                return Stack(
                      alignment: Alignment.center,
                      children: [
                        NumberPicker(
                          axis: Axis.horizontal,
                          minValue: 1,
                          maxValue: ProductsScreenService.maxQuantity,
                          value: quantity,
                          itemCount: _visibleItems,
                          itemWidth: itemWidth,
                          itemHeight: TwSpacing.s20,
                          haptics: true,
                          onChanged: (value) => selected.value = value,
                          textStyle: TextStyle(
                            color: colors.textSecondary,
                            fontSize: TwFontSize.lg,
                            fontWeight: TwFontWeight.medium,
                          ),
                          selectedTextStyle: TextStyle(
                            color: colors.textPrimary,
                            fontSize: TwFontSize.xl2,
                            fontWeight: TwFontWeight.semibold,
                          ),
                        ),
                        const SizedBox(width: _tickWidth, height: _tickHeight)
                            .backgroundColor(colors.textSecondary)
                            .positioned(top: TwSpacing.s2),
                        const SizedBox(width: _tickWidth, height: _tickHeight)
                            .backgroundColor(colors.textSecondary)
                            .positioned(bottom: TwSpacing.s2),
                        _fade(
                          colors.surfaceMuted,
                          Alignment.centerLeft,
                          Alignment.centerRight,
                        ).positioned(left: 0, top: 0, bottom: 0),
                        _fade(
                          colors.surfaceMuted,
                          Alignment.centerRight,
                          Alignment.centerLeft,
                        ).positioned(right: 0, top: 0, bottom: 0),
                      ],
                    )
                    .clipRRect(all: TwRadius.xl2)
                    .gestures(
                      behavior: HitTestBehavior.opaque,
                      onTapUp: (details) =>
                          _selectAt(details.localPosition.dx, itemWidth),
                    );
              },
            ).decorated(
              color: colors.surfaceMuted,
              borderRadius: BorderRadius.circular(TwRadius.xl2),
            ),
            Row(
              spacing: TwSpacing.s3,
              children: [
                if (hasExisting)
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(0),
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.surfaceMuted,
                      foregroundColor: colors.textPrimary,
                      minimumSize: const Size(0, TwSpacing.s14),
                      padding: const EdgeInsets.symmetric(
                        horizontal: TwSpacing.s4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(TwRadius.xl2),
                      ),
                      textStyle: const TextStyle(
                        fontSize: TwFontSize.base,
                        fontWeight: TwFontWeight.semibold,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: TwSpacing.s1_5,
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedMinusSignCircle,
                          color: colors.danger,
                          size: TwSpacing.s5,
                        ),
                        const Text('Remove'),
                      ],
                    ),
                  ),
                FilledButton(
                  onPressed: changed
                      ? () => Navigator.of(context).pop(quantity)
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: BrandColors.accent500,
                    foregroundColor: colors.textOnAccent,
                    disabledBackgroundColor: colors.surfaceMuted,
                    disabledForegroundColor: colors.textSecondary,
                    minimumSize: const Size(double.infinity, TwSpacing.s14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(TwRadius.xl2),
                    ),
                    textStyle: const TextStyle(
                      fontSize: TwFontSize.base,
                      fontWeight: TwFontWeight.semibold,
                    ),
                  ),
                  child: Text(
                    hasExisting ? 'Update Basket' : 'Add $quantity to Basket',
                  ),
                ).expanded(),
              ],
            ),
          ],
        ).padding(
          left: TwSpacing.s4,
          right: TwSpacing.s4,
          bottom: TwSpacing.s4 + bottomInset,
        );
      },
    );
  }
}

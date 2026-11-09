import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../theme/theme.dart';

class ProductCardShimmer extends StatelessWidget {
  const ProductCardShimmer({super.key});

  static const double _imageSize = 72;
  static const double _addWidth = TwSpacing.s24;
  static const double _addHeight = TwSpacing.s11;
  static const double _heartSize = TwSpacing.s6;
  static const double _storeRowHeight = TwSpacing.s7;
  static const double _storeLogo = TwSpacing.s4;
  static const double _seeMoreHeight = TwSpacing.s7;
  static const double _hairline = 0.5;
  static const Duration _period = Duration(milliseconds: 1400);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dark = Theme.brightnessOf(context) == Brightness.dark;
    final highlight = dark
        ? TwColors.zinc.s700
        : Color.lerp(colors.surfaceMuted, colors.surface, 0.55)!;
    final enabled = !(MediaQuery.maybeDisableAnimationsOf(context) ?? false);

    Widget shimmer(Widget child) => Shimmer.fromColors(
      baseColor: colors.surfaceMuted,
      highlightColor: highlight,
      period: _period,
      enabled: enabled,
      child: child,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        shimmer(_mainContent(colors))
            .padding(all: TwSpacing.s3)
            .decorated(
              color: colors.surface,
              borderRadius: BorderRadius.circular(TwRadius.xl2),
              boxShadow: [
                BoxShadow(
                  color: colors.textPrimary.withValues(alpha: 0.04),
                  blurRadius: TwSpacing.s1_5,
                ),
              ],
            ),
        const SizedBox(height: TwSpacing.s1),
        shimmer(_storesContent(colors)).decorated(
          color: colors.surface,
          borderRadius: BorderRadius.circular(TwRadius.xl2),
          border: Border.all(
            color: colors.border.withValues(alpha: 0.6),
            width: _hairline,
          ),
        ),
      ],
    );
  }

  Widget _mainContent(AppColors colors) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _mainRow(colors),
        Positioned(
          top: -TwSpacing.s1_5,
          right: -TwSpacing.s1_5,
          child: _block(
            colors,
            width: _heartSize,
            height: _heartSize,
            radius: TwRadius.full,
          ),
        ),
      ],
    );
  }

  Widget _mainRow(AppColors colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _block(
          colors,
          width: _imageSize,
          height: _imageSize,
          radius: TwRadius.lg,
        ),
        const SizedBox(width: TwSpacing.s2),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _block(colors, height: TwSpacing.s3).expanded(),
                const SizedBox(width: TwSpacing.s10),
              ],
            ),
            const SizedBox(height: TwSpacing.s1_5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _block(colors, width: 76, height: TwSpacing.s6),
                    const SizedBox(height: TwSpacing.s1_5),
                    _block(colors, width: 92, height: TwSpacing.s2_5),
                    const SizedBox(height: TwSpacing.s1_5),
                    Row(
                      children: [
                        _block(
                          colors,
                          width: _storeLogo,
                          height: _storeLogo,
                          radius: TwRadius.sm,
                        ),
                        const SizedBox(width: TwSpacing.s1_5),
                        _block(colors, width: 64, height: TwSpacing.s2_5),
                      ],
                    ),
                  ],
                ).expanded(),
                _block(
                  colors,
                  width: _addWidth,
                  height: _addHeight,
                  radius: TwRadius.full,
                ),
              ],
            ),
          ],
        ).expanded(),
      ],
    );
  }

  Widget _storesContent(AppColors colors) {
    return Column(
      children: [
        _storeRow(colors),
        const SizedBox(
          width: double.infinity,
          height: _hairline,
        ).backgroundColor(colors.border),
        _storeRow(colors),
        const SizedBox(
          width: double.infinity,
          height: _hairline,
        ).backgroundColor(colors.border),
        _storeRow(colors),
        Center(child: _block(colors, width: 64, height: TwSpacing.s2_5))
            .constrained(height: _seeMoreHeight),
      ],
    );
  }

  Widget _storeRow(AppColors colors) {
    return Row(
      children: [
        _block(
          colors,
          width: _storeLogo,
          height: _storeLogo,
          radius: TwRadius.sm,
        ),
        const SizedBox(width: TwSpacing.s3),
        _block(colors, width: 120, height: TwSpacing.s2_5),
        const Spacer(),
        _block(colors, width: 40, height: TwSpacing.s2_5),
      ],
    ).padding(horizontal: TwSpacing.s3).constrained(height: _storeRowHeight);
  }

  Widget _block(
    AppColors colors, {
    double? width,
    required double height,
    double radius = TwRadius.sm,
  }) {
    return SizedBox(width: width, height: height).decorated(
      color: colors.surfaceMuted,
      borderRadius: BorderRadius.circular(radius),
    );
  }
}

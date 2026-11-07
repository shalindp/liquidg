import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../theme/theme.dart';
import 'product_card_controller.dart';

part 'common/product_image.dart';
part 'common/product_title_row.dart';
part 'common/product_price_row.dart';
part 'common/store_prices.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({super.key});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  final _controller = ProductCardController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final c = _controller;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProductImage(url: c.imageUrl)
                    .constrained(width: 79, height: 79),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _TitleRow(
                      name: c.name,
                      favourite: c.favourite,
                      onFavourite: c.toggleFavourite,
                    ),
                    const SizedBox(height: TwSpacing.s0),
                    _PriceRow(price: c.lowestPrice, unitPrice: c.unitPrice),
                  ],
                ).padding(left: TwSpacing.s2).expanded(),
              ],
            )
            .padding(all: TwSpacing.s3)
            .decorated(
              color: colors.surface,
              borderRadius: BorderRadius.circular(TwRadius.xl2),
              boxShadow: [
                BoxShadow(
                  color: colors.textPrimary.withValues(alpha: 0.04),
                  blurRadius: TwSpacing.s3,
                ),
              ],
            ),
        const SizedBox(height: TwSpacing.s1),
        _StorePrices(controller: c),
      ],
    );
  }
}

import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../theme/theme.dart';
import '../../models/product_item.dart';
import '../../models/supermarket.dart';
import '../../service_locator.dart';
import '../../services/products_screen_service.dart';
import 'product_card_controller.dart';

part 'common/product_image.dart';
part 'common/product_title_row.dart';
part 'common/product_price_row.dart';
part 'common/store_label.dart';
part 'common/store_prices.dart';
part 'common/add_to_cart_sheet.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({super.key, required this.item});

  final ProductItem item;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late final _controller = ProductCardController(
    widget.item,
    getIt<ProductsScreenService>(),
  );

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
        Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProductImage(url: c.imageUrl).constrained(
                      width: _ProductImage.size,
                      height: _ProductImage.size,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _TitleRow(name: c.name),
                        const SizedBox(height: TwSpacing.s0),
                        _PriceRow(
                          price: c.lowestPrice,
                          chain: c.lowestStore.chain,
                          store: c.lowestStore.branch,
                          unitPrice: c.unitPrice,
                          controller: c,
                        ),
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
                      blurRadius: TwSpacing.s1_5,
                    ),
                  ],
                ),
            Positioned(
              top: TwSpacing.s1_5,
              right: TwSpacing.s1_5,
              child: _FavouriteButton(
                favourite: c.favourite,
                onPressed: c.toggleFavourite,
              ),
            ),
          ],
        ),
        const SizedBox(height: TwSpacing.s1),
        _StorePrices(controller: c),
      ],
    );
  }
}

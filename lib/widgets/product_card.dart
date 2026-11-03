import 'package:flutter/material.dart';
import 'package:mix/mix.dart';

import '../theme/theme.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.name,
    required this.price,
    required this.color,
  });

  final String name;
  final String price;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cardStyle = BoxStyler()
        .padding(.all($space3()))
        .borderRadius(.all($radius2xl()))
        .color($surface());

    final imageStyle = BoxStyler()
        .size(72, 72)
        .borderRadius(.all($radiusXl()))
        .color(color)
        .alignment(.center);

    final nameStyle = TextStyler()
        .fontSize(16)
        .fontWeight(.w600)
        .color($textPrimary())
        .maxLines(2);

    final priceStyle = TextStyler()
        .fontSize(14)
        .fontWeight(.w500)
        .color($textSecondary());

    return Box(
      style: cardStyle,
      child: Row(
        children: [
          Box(
            style: imageStyle,
            child: const Icon(
              Icons.shopping_basket_outlined,
              color: TwColors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: TwSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StyledText(name, style: nameStyle),
                const SizedBox(height: TwSpacing.s1),
                StyledText(price, style: priceStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

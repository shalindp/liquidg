import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../widgets/product_card.dart';
import '../widgets/search_header.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  static const _names = <String>[
    'Tasty Cheese 500g',
    'Full Cream Milk 2L',
    'Free Range Eggs 12pk',
    'Sourdough Loaf',
    'Greek Yoghurt 1kg',
    'Bananas',
    'Chicken Breast 1kg',
    'Pasta Penne 500g',
    'Olive Oil 750ml',
    'Orange Juice 2L',
  ];

  static final _palette = <Color>[
    TwColors.red.s400,
    TwColors.amber.s400,
    TwColors.teal.s400,
    TwColors.blue.s400,
    TwColors.violet.s400,
    TwColors.pink.s400,
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        TwSpacing.s4,
        SearchHeader.heightOf(context) + TwSpacing.s3,
        TwSpacing.s4,
        TwSpacing.s28 + TwSpacing.s2,
      ),
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      itemCount: 40,
      separatorBuilder: (_, _) => const SizedBox(height: TwSpacing.s3),
      itemBuilder: (context, i) => ProductCard(
        name: _names[i % _names.length],
        price: '\$${(2 + (i * 1.37) % 18).toStringAsFixed(2)}',
        color: _palette[i % _palette.length],
      ),
    );
  }
}

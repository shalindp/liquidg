import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;

import '../theme/theme.dart';
import '../widgets/collapsing_header.dart';
import '../widgets/product_card/product_card.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        TwSpacing.s4,
        CollapsingHeader.heightOf(context) + TwSpacing.s3,
        TwSpacing.s4,
        TwSpacing.s28 + TwSpacing.s2,
      ),
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      scrollCacheExtent: const ScrollCacheExtent.viewport(1),
      itemCount: 300,
      separatorBuilder: (_, _) => const SizedBox(height: TwSpacing.s3),
      itemBuilder: (context, i) => const ProductCard(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:signals_flutter/signals_flutter.dart';

import '../service_locator.dart';
import '../services/products_screen_service.dart';
import '../theme/theme.dart';
import '../widgets/collapsing_header.dart';
import '../widgets/product_card/product_card.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _service = getIt<ProductsScreenService>();

  @override
  void initState() {
    super.initState();
    _service.load();
  }

  @override
  Widget build(BuildContext context) {
    final padding = EdgeInsets.fromLTRB(
      TwSpacing.s4,
      CollapsingHeader.heightOf(context) + TwSpacing.s3,
      TwSpacing.s4,
      TwSpacing.s28 + TwSpacing.s2,
    );
    return SignalBuilder(
      builder: (context) {
        final products = _service.products.value;
        if (products.isEmpty) {
          return _Message(
            padding: padding,
            loading: _service.loading.value,
            error: _service.error.value,
            onRetry: _service.refresh,
          );
        }
        return ListView.separated(
          padding: padding,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          scrollCacheExtent: const ScrollCacheExtent.viewport(1),
          itemCount: products.length,
          separatorBuilder: (_, _) => const SizedBox(height: TwSpacing.s3),
          itemBuilder: (context, i) {
            final product = products[i];
            return ProductCard(
              key: ValueKey(product.productId),
              name: product.name,
              imageUrl: product.imageUrls.isEmpty
                  ? null
                  : product.imageUrls.first,
            );
          },
        );
      },
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.padding,
    required this.loading,
    required this.error,
    required this.onRetry,
  });

  final EdgeInsets padding;
  final bool loading;
  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final String? text = loading
        ? null
        : error != null
        ? 'Could not load products'
        : 'No products found';
    return Padding(
      padding: padding,
      child: Center(
        child: text == null
            ? const CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: TwFontSize.base,
                    ),
                  ),
                  const SizedBox(height: TwSpacing.s3),
                  TextButton(onPressed: onRetry, child: const Text('Retry')),
                ],
              ),
      ),
    );
  }
}

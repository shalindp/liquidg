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
  static const double _loadMoreThreshold = 2000;

  final _service = getIt<ProductsScreenService>();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _service.loadMore();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.extentAfter < _loadMoreThreshold) {
      _service.loadMore();
    }
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
        final footer = _service.loading.value || _service.error.value != null;
        return ListView.separated(
          controller: _scroll,
          padding: padding,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          scrollCacheExtent: const ScrollCacheExtent.viewport(1),
          itemCount: products.length + (footer ? 1 : 0),
          separatorBuilder: (_, _) => const SizedBox(height: TwSpacing.s3),
          itemBuilder: (context, i) {
            if (i == products.length) {
              return _Footer(
                error: _service.error.value != null,
                onRetry: _service.loadMore,
              );
            }
            final item = products[i];
            return ProductCard(key: ValueKey(item.id), item: item);
          },
        );
      },
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.error, required this.onRetry});

  final bool error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: error
          ? TextButton(onPressed: onRetry, child: const Text('Retry'))
          : const Padding(
              padding: EdgeInsets.all(TwSpacing.s4),
              child: CircularProgressIndicator(),
            ),
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

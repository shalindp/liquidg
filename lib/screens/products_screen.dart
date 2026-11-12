import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../service_locator.dart';
import '../services/products_screen_service.dart';
import '../theme/theme.dart';
import '../widgets/collapsing_header.dart';
import '../widgets/product_card/product_card.dart';
import '../widgets/product_card/product_card_shimmer.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  static const double _loadMoreThreshold = 2000;

  final _service = getIt<ProductsScreenService>();
  final _scroll = _ProbeController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _service.loadMore();
    _service.loadCategories();
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
    final top = CollapsingHeader.heightOf(context);
    const bottom = TwSpacing.s28 + TwSpacing.s2;
    return SignalBuilder(
      builder: (context) {
        final products = _service.products.value;
        if (products.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Message(
                loading: _service.loading.value,
                error: _service.error.value,
                term: _service.barcode ?? _service.searchTerm,
                onRetry: _service.refresh,
              ).expanded(),
            ],
          ).padding(top: top, bottom: bottom);
        }
        final footer = _service.loading.value || _service.error.value != null;
        return ListView.builder(
          controller: _scroll,
          padding: EdgeInsets.only(top: top + TwSpacing.s3, bottom: bottom),
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          scrollCacheExtent: const ScrollCacheExtent.viewport(1),
          itemCount: products.length + (footer ? 1 : 0),
          itemBuilder: (context, i) {
            if (i == products.length) {
              return _Footer(
                error: _service.error.value != null,
                onRetry: _service.loadMore,
              );
            }
            final item = products[i];
            return ProductCard(key: ValueKey(item.id), item: item).padding(
              left: TwSpacing.s4,
              right: TwSpacing.s4,
              bottom: TwSpacing.s3,
            );
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
    if (error) {
      return Center(
        child: TextButton(onPressed: onRetry, child: const Text('Retry')),
      );
    }
    return const ProductCardShimmer().padding(
      left: TwSpacing.s4,
      right: TwSpacing.s4,
      bottom: TwSpacing.s3,
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.loading,
    required this.error,
    required this.term,
    required this.onRetry,
  });

  static const int _shimmerCount = 4;

  final bool loading;
  final Object? error;
  final String term;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (loading) {
      return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: TwSpacing.s3),
        itemCount: _shimmerCount,
        itemBuilder: (context, i) => const ProductCardShimmer().padding(
          left: TwSpacing.s4,
          right: TwSpacing.s4,
          bottom: TwSpacing.s3,
        ),
      );
    }
    if (error == null) {
      return Center(child: _NoResults(term: term));
    }
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Could not load products',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: TwFontSize.base,
            ),
          ),
          const SizedBox(height: TwSpacing.s3),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({required this.term});

  static const String _illustration = 'assets/illustrations/no_results.svg';
  static const double _illustrationHeight = 200;
  static const Color _sourceGreen = Color(0xFF00761A);

  final String term;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: TwSpacing.s4,
      children: [
        SvgPicture.asset(
          _illustration,
          height: _illustrationHeight,
          colorMapper: _BrandColorMapper(
            from: _sourceGreen,
            to: BrandColors.accent500,
          ),
        ),
        Column(
          spacing: TwSpacing.s2,
          children: [
            Text(
              'Yeah, nah. Nothing for \u201c$term\u201d',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: TwFontSize.lg,
                fontWeight: TwFontWeight.semibold,
              ),
            ),
            Text(
              'Check the spelling, try a more general term, or search without the brand name.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: TwFontSize.sm,
              ),
            ),
          ],
        ),
      ],
    ).padding(horizontal: TwSpacing.s8);
  }
}

class _BrandColorMapper extends ColorMapper {
  const _BrandColorMapper({required this.from, required this.to});

  final Color from;
  final Color to;

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) => color == from ? to : color;
}

class _ProbeController extends ScrollController {
  @override
  ScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) => _ProbePosition(
    physics: physics,
    context: context,
    oldPosition: oldPosition,
  );
}

class _ProbePosition extends ScrollPositionWithSingleContext {
  _ProbePosition({
    required super.physics,
    required super.context,
    super.oldPosition,
  });

  @override
  void correctBy(double correction) {
    File(
      '/private/tmp/claude-501/-Users-shalinda---dev-liquidg/930e3cc2-b1d2-46f6-9c6c-6de6f7ca6cf9/scratchpad/probe.log',
    ).writeAsStringSync(
      'correctBy ${correction.toStringAsFixed(1)} at ${pixels.toStringAsFixed(1)} max ${maxScrollExtent.toStringAsFixed(1)}\n',
      mode: FileMode.append,
    );
    super.correctBy(correction);
  }
}

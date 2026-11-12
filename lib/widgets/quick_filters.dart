import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shimmer/shimmer.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:styled_widget/styled_widget.dart';

import '../service_locator.dart';
import '../services/products_screen_service.dart';
import '../theme/theme.dart';
import '../utils/number_util.dart';
import 'products_filters_sheet.dart';

class QuickFilters extends StatefulWidget {
  const QuickFilters({super.key});

  static const double height = TwSpacing.s9;
  static const double bleed = TwSpacing.s1;
  static const double extent = height + bleed;

  @override
  State<QuickFilters> createState() => _QuickFiltersState();
}

class _QuickFiltersState extends State<QuickFilters> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _pick(ProductsScreenService service, String path) {
    service.selectQuickCategory(path);
    if (_scroll.hasClients) {
      _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  double get _pull =>
      _scroll.hasClients ? math.max(0, -_scroll.position.pixels) : 0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final service = getIt<ProductsScreenService>();
    return SignalBuilder(
      builder: (context) {
        final selected = {?service.quickCategory.value};
        final visible = [
          for (final category in service.categories.value)
            if (category.productCount > 0) category,
        ];
        final categories = [
          for (final category in visible)
            if (selected.contains(category.path)) category,
          for (final category in visible)
            if (!selected.contains(category.path)) category,
        ];
        final active = service.activeFilterCount.value;
        final loading = service.categoriesLoading.value;
        return CustomScrollView(
          controller: _scroll,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            PinnedHeaderSliver(
              child: Padding(
                padding: const EdgeInsets.only(top: QuickFilters.bleed),
                child: ListenableBuilder(
                  listenable: _scroll,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(_pull, 0),
                    child: child,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _FilterButton(
                            active: active,
                            onTap: () => showProductsFiltersSheet(context),
                          )
                          .padding(left: TwSpacing.s4)
                          .backgroundColor(colors.background),
                      const SizedBox(
                        width: TwSpacing.s2,
                        height: QuickFilters.height,
                      ).decorated(
                        gradient: LinearGradient(
                          colors: [
                            colors.background,
                            colors.background.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (loading)
              const SliverToBoxAdapter(child: _ChipsShimmer())
            else
              SliverPadding(
                padding: const EdgeInsets.only(right: TwSpacing.s4),
                sliver: SliverList.separated(
                  itemCount: categories.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: TwSpacing.s2),
                  itemBuilder: (context, i) {
                    final category = categories[i];
                    return Align(
                      alignment: Alignment.bottomCenter,
                      child: _Chip(
                        label: category.name,
                        selected: selected.contains(category.path),
                        onTap: () => _pick(service, category.path),
                      ),
                    );
                  },
                ),
              ),
          ],
        ).constrained(height: QuickFilters.extent);
      },
    );
  }
}

class _ChipsShimmer extends StatelessWidget {
  const _ChipsShimmer();

  static const List<double> _widths = [72, 104, 88, 120, 96, 110];
  static const Duration _period = Duration(milliseconds: 1400);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dark = Theme.brightnessOf(context) == Brightness.dark;
    final highlight = dark
        ? TwColors.zinc.s700
        : Color.lerp(colors.surfaceMuted, colors.surface, 0.55)!;
    final enabled = !(MediaQuery.maybeDisableAnimationsOf(context) ?? false);
    return Shimmer.fromColors(
      baseColor: colors.surfaceMuted,
      highlightColor: highlight,
      period: _period,
      enabled: enabled,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: TwSpacing.s2,
        children: [
          for (final width in _widths)
            SizedBox(width: width, height: QuickFilters.height).decorated(
              color: colors.surfaceMuted,
              borderRadius: BorderRadius.circular(TwRadius.full),
            ),
        ],
      ),
    ).padding(right: TwSpacing.s4).constrained(height: QuickFilters.extent);
  }
}

class ProductsCountRow extends StatelessWidget {
  const ProductsCountRow({super.key});

  static const double _hairline = 0.5;
  static const double _bottom = TwSpacing.s0_5;
  static const double _top = TwSpacing.s0_5;
  static const double height = _top + TwSpacing.s5 + _bottom + _hairline;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final service = getIt<ProductsScreenService>();
    return SignalBuilder(
      builder: (context) {
        final total = service.total.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: _top),
            Text(
                  total == null
                      ? ''
                      : total == 1
                      ? '1 Product'
                      : '${total.grouped} Products',
                  style: TextStyle(
                    color: colors.textPrimary.withValues(alpha: 0.65),
                    fontSize: TwFontSize.xs,
                    fontWeight: TwFontWeight.normal,
                  ),
                )
                .padding(horizontal: TwSpacing.s4)
                .alignment(Alignment.centerLeft)
                .constrained(height: TwSpacing.s5),
            const SizedBox(height: _bottom),
            const SizedBox(height: _hairline).backgroundColor(colors.border),
          ],
        );
      },
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.active, required this.onTap});

  static const double _dot = TwSpacing.s2;

  final int active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Row(
              mainAxisSize: MainAxisSize.min,
              spacing: TwSpacing.s2,
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedFilterVertical,
                  color: colors.textPrimary,
                  size: TwSpacing.s5,
                ),
                Text(
                  'Filter',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: TwFontSize.sm,
                    fontWeight: TwFontWeight.medium,
                  ),
                ),
              ],
            )
            .padding(horizontal: TwSpacing.s3)
            .constrained(height: QuickFilters.height)
            .decorated(
              color: colors.surface,
              borderRadius: BorderRadius.circular(TwRadius.full),
              border: Border.all(color: colors.border),
            )
            .gestures(behavior: HitTestBehavior.opaque, onTap: onTap),
        if (active > 0)
          IgnorePointer(
            child: const SizedBox(
              width: _dot,
              height: _dot,
            ).decorated(color: BrandColors.accent500, shape: BoxShape.circle),
          ).positioned(top: TwSpacing.s0_5, right: TwSpacing.s0_5),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  static const double _tintAlpha = 0.06;
  static const double _borderAlpha = 0.45;

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      height: QuickFilters.height,
      padding: const EdgeInsets.symmetric(horizontal: TwSpacing.s3),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected
            ? BrandColors.accent500.withValues(alpha: _tintAlpha)
            : colors.surface,
        borderRadius: BorderRadius.circular(TwRadius.full),
        border: Border.all(
          color: selected
              ? BrandColors.accent500.withValues(alpha: _borderAlpha)
              : colors.border,
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        style: TextStyle(
          color: colors.textPrimary,
          fontSize: TwFontSize.sm,
          fontWeight: TwFontWeight.medium,
        ),
      ),
    ).gestures(behavior: HitTestBehavior.opaque, onTap: onTap);
  }
}

part of '../product_card.dart';

const double _rowHeight = TwSpacing.s7;
const double _hairlineWidth = 0.5;

Color _hairline(AppColors colors) => colors.border.withValues(alpha: 0.6);

class _StorePrices extends StatelessWidget {
  const _StorePrices({required this.controller});

  final ProductCardController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final c = controller;
    return SignalBuilder(
      builder: (context) {
        final expanded = c.storesExpanded.value;
        final count = c.visibleCount.value;
        final scrollable =
            expanded && c.stores.length > ProductCardController.expandedLimit;
        return AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: Column(
            children: [
              _StoreList(
                lowest: c.lowest,
                stores: c.stores,
                count: count,
                scrollable: scrollable,
              ),
              if (c.canExpand)
                _SeeMoreButton(expanded: expanded, onPressed: c.toggleStores),
            ],
          ),
        );
      },
    ).decorated(
      color: colors.surface,
      borderRadius: BorderRadius.circular(TwRadius.xl2),
      border: Border.all(color: _hairline(colors), width: _hairlineWidth),
    );
  }
}

class _StoreList extends StatelessWidget {
  const _StoreList({
    required this.lowest,
    required this.stores,
    required this.count,
    required this.scrollable,
  });

  final double lowest;
  final List<StorePrice> stores;
  final int count;
  final bool scrollable;

  bool _handOver(BuildContext context, OverscrollNotification n) {
    final outer = Scrollable.maybeOf(context)?.position;
    if (outer == null || n.dragDetails == null) return false;
    final target = (outer.pixels + n.overscroll).clamp(
      outer.minScrollExtent,
      outer.maxScrollExtent,
    );
    if (target != outer.pixels) outer.jumpTo(target);
    return false;
  }

  Widget _row(int i) => SizedBox(
    height: _rowHeight,
    child: _StoreRow(store: stores[i], lowest: lowest, divider: i > 0),
  );

  @override
  Widget build(BuildContext context) {
    if (!scrollable) {
      return Column(children: [for (var i = 0; i < count; i++) _row(i)]);
    }
    return NotificationListener<OverscrollNotification>(
      onNotification: (n) => _handOver(context, n),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        physics: const ClampingScrollPhysics(),
        itemExtent: _rowHeight,
        itemCount: stores.length,
        itemBuilder: (context, i) => _row(i),
      ),
    ).constrained(height: count * _rowHeight);
  }
}

class _StoreRow extends StatelessWidget {
  const _StoreRow({
    required this.store,
    required this.lowest,
    required this.divider,
  });

  final StorePrice store;
  final double lowest;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final delta = store.deltaFrom(lowest);
    return Row(
          children: [
            _StoreLabel(store: store).expanded(),
            if (delta != null) ...[
              Text(
                delta,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: TwFontSize.xs,
                  fontWeight: TwFontWeight.normal,
                ),
              ),
              const SizedBox(width: TwSpacing.s2),
            ],
            Text(
              store.label,
              style: TextStyle(
                color: store.available
                    ? colors.textPrimary
                    : colors.textSecondary.withValues(alpha: 0.6),
                fontSize: store.available ? TwFontSize.sm : TwFontSize.xs,
                fontWeight: TwFontWeight.normal,
              ),
            ),
          ],
        )
        .padding(horizontal: TwSpacing.s3)
        .decorated(
          border: divider
              ? Border(
                  top: BorderSide(
                    color: _hairline(colors),
                    width: _hairlineWidth,
                  ),
                )
              : null,
        );
  }
}

class _SeeMoreButton extends StatelessWidget {
  const _SeeMoreButton({required this.expanded, required this.onPressed});

  final bool expanded;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              expanded ? 'See less' : 'See more',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: TwFontSize.xs,
                fontWeight: TwFontWeight.medium,
              ),
            ),
            const SizedBox(width: TwSpacing.s1),
            HugeIcon(
              icon: expanded
                  ? HugeIcons.strokeRoundedChevronUp
                  : HugeIcons.strokeRoundedChevronDown,
              color: colors.textSecondary,
              size: TwSpacing.s4,
            ),
          ],
        )
        .constrained(height: TwSpacing.s5)
        .padding(bottom: TwSpacing.s2)
        .gestures(onTap: onPressed, behavior: HitTestBehavior.opaque);
  }
}

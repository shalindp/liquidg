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
            final height = c.visibleCount.value * _rowHeight;
            final expanded = c.storesExpanded.value;
            return AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              child: Column(
                children: [
                  _StoreList(
                    lowest: c.lowestStore.price,
                    stores: c.stores,
                    height: height,
                    scrollable: expanded,
                  ),
                  if (c.canExpand)
                    _SeeMoreButton(
                      expanded: expanded,
                      onPressed: c.toggleStores,
                    ),
                ],
              ),
            );
          },
        )
        .decorated(
          color: colors.surface,
          borderRadius: BorderRadius.circular(TwRadius.xl2),
          border: Border.all(color: _hairline(colors), width: _hairlineWidth),
        )
        .clipRRect(all: TwRadius.xl2);
  }
}

class _StoreList extends StatefulWidget {
  const _StoreList({
    required this.lowest,
    required this.stores,
    required this.height,
    required this.scrollable,
  });

  final double lowest;
  final List<StorePrice> stores;
  final double height;
  final bool scrollable;

  @override
  State<_StoreList> createState() => _StoreListState();
}

class _StoreListState extends State<_StoreList> {
  final _scroll = ScrollController();

  @override
  void didUpdateWidget(_StoreList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollable && !widget.scrollable && _scroll.hasClients) {
      _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    return NotificationListener<OverscrollNotification>(
      onNotification: (n) => _handOver(context, n),
      child: ListView.builder(
        controller: _scroll,
        padding: EdgeInsets.zero,
        physics: widget.scrollable
            ? const ClampingScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        itemExtent: _rowHeight,
        itemCount: widget.stores.length,
        itemBuilder: (context, i) => _StoreRow(
          store: widget.stores[i],
          lowest: widget.lowest,
          divider: i > 0,
        ),
      ),
    ).constrained(height: widget.height);
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
    return Row(
          children: [
            SvgPicture.asset(
              'assets/icons/woolworths_logo.svg',
              width: TwSpacing.s4,
              height: TwSpacing.s4,
            ),
            const SizedBox(width: TwSpacing.s3),
            Text.rich(
              TextSpan(
                text: '${store.chain} ',
                style: TextStyle(
                  fontSize: TwFontSize.xs,
                  fontWeight: TwFontWeight.normal,
                ),
                children: [
                  TextSpan(
                    text: store.branch,
                    style: TextStyle(
                      fontSize: TwFontSize.sm,
                      fontWeight: TwFontWeight.normal,
                    ),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colors.textPrimary),
            ).expanded(),
            Text(
              store.deltaFrom(lowest),
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: TwFontSize.xs,
                fontWeight: TwFontWeight.normal,
              ),
            ),
            const SizedBox(width: TwSpacing.s2),
            Text(
              store.label,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: TwFontSize.sm,
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

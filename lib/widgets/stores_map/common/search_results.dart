part of '../stores_map.dart';

class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.results,
    required this.selectedIds,
    required this.onToggle,
  });

  final List<StoreDistance> results;
  final Set<int> selectedIds;
  final ValueChanged<StoreLocation> onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Align(
      alignment: Alignment.topCenter,
      child:
          (results.isEmpty
                  ? Text(
                          'No stores found',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: TwFontSize.sm,
                          ),
                        )
                        .padding(all: TwSpacing.s4)
                        .constrained(width: double.infinity)
                  : ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: results.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: _hairline)
                              .backgroundColor(colors.border),
                      itemBuilder: (context, index) {
                        final entry = results[index];
                        return _SearchResultItem(
                          entry: entry,
                          selected: selectedIds.contains(entry.store.id),
                          onTap: () => onToggle(entry.store),
                        );
                      },
                    ))
              .decorated(
                color: colors.surface,
                borderRadius: BorderRadius.circular(TwRadius.xl2),
                border: Border.all(color: colors.border, width: _hairline),
                boxShadow: _panel(colors).boxShadow,
              )
              .clipRRect(all: TwRadius.xl2),
    );
  }
}

class _SearchResultItem extends StatelessWidget {
  const _SearchResultItem({
    required this.entry,
    required this.selected,
    required this.onTap,
  });

  static const double _logo = TwSpacing.s7;
  static const double _bar = 3;
  static const double _tick = 14;
  static const double _tickIcon = 10;
  static const double _tickOffset = -4;

  final StoreDistance entry;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final store = entry.store;
    return Row(
          spacing: TwSpacing.s3,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                SupermarketLogo(chain: store.supermarket, size: _logo),
                if (selected)
                  HugeIcon(
                        icon: HugeIcons.strokeRoundedTick02,
                        size: _tickIcon,
                        color: colors.textOnAccent,
                      )
                      .center()
                      .constrained(width: _tick, height: _tick)
                      .decorated(
                        color: BrandColors.accent500,
                        shape: BoxShape.circle,
                      )
                      .positioned(right: _tickOffset, bottom: _tickOffset),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: TwFontSize.base,
                    fontWeight: TwFontWeight.medium,
                  ),
                ),
                Text(
                  store.supermarket.label,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: TwFontSize.xs,
                  ),
                ),
              ],
            ).expanded(),
            Text(
              GeoUtil.formatKilometres(entry.kilometres),
              maxLines: 1,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: TwFontSize.sm,
                fontWeight: TwFontWeight.semibold,
              ),
            ),
          ],
        )
        .padding(horizontal: TwSpacing.s4, vertical: TwSpacing.s3)
        .decorated(
          border: Border(
            left: BorderSide(
              color: selected ? BrandColors.accent500 : Colors.transparent,
              width: _bar,
            ),
          ),
        )
        .gestures(behavior: HitTestBehavior.opaque, onTap: onTap);
  }
}

part of '../stores_map.dart';

class _SelectedTray extends StatelessWidget {
  const _SelectedTray({
    required this.entries,
    required this.expanded,
    required this.onToggle,
    required this.onRemove,
    required this.onReset,
  });

  static const double collapsedHeight = TwSpacing.s14;
  static const double _expandedHeader = TwSpacing.s12;
  static const double _listMaxHeight = 280;
  static const double _avatar = 28;
  static const double _avatarLogo = 18;
  static const double _avatarOverlap = 16;
  static const int _maxAvatars = 3;
  static const double _rowLogo = 28;
  static const double _icon = TwSpacing.s5;

  final List<StoreDistance> entries;
  final bool expanded;
  final VoidCallback onToggle;
  final ValueChanged<StoreLocation> onRemove;
  final VoidCallback onReset;

  static const double boxHeight = _expandedHeader + _listMaxHeight + _hairline;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final brightness = Theme.brightnessOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = expanded
            ? constraints.maxWidth
            : constraints.maxWidth - _RecenterButton.size - TwSpacing.s3;
        return LiquidGlassMorph(
          alignment: Alignment.bottomLeft,
          width: width,
          motion: LiquidGlassMorphMotion.calm,
          style: AppGlass.foldedStyle(brightness).copyWith(
            shape: LiquidGlassShape.roundedRectangle(
              cornerRadius: expanded ? TwRadius.xl2 : collapsedHeight / 2,
            ),
          ),
          child: expanded
              ? SizedBox(
                  key: const ValueKey('expanded'),
                  width: width,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxHeight: _listMaxHeight,
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: entries.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: _hairline)
                                  .backgroundColor(colors.border),
                          itemBuilder: (context, index) => _row(
                            colors,
                            entries[index],
                            removable: entries.length > 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: _hairline)
                          .backgroundColor(colors.border),
                      _header(colors),
                    ],
                  ),
                )
              : SizedBox(
                  key: const ValueKey('collapsed'),
                  width: width,
                  child: _header(colors),
                ),
        );
      },
    );
  }

  Widget _header(AppColors colors) {
    final count = entries.length;
    final label = expanded
        ? 'Selected ($count)'
        : '$count ${count == 1 ? 'store' : 'stores'} selected';
    return Row(
          spacing: TwSpacing.s2,
          children: [
            if (!expanded) _avatars(colors),
            Text(
              label,
              maxLines: 1,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: TwFontSize.sm,
                fontWeight: TwFontWeight.semibold,
              ),
            ).expanded(),
            if (expanded)
              Text(
                    'Reset',
                    style: TextStyle(
                      color: colors.danger,
                      fontSize: TwFontSize.sm,
                      fontWeight: TwFontWeight.medium,
                    ),
                  )
                  .padding(horizontal: TwSpacing.s2, vertical: TwSpacing.s2)
                  .gestures(behavior: HitTestBehavior.opaque, onTap: onReset),
            HugeIcon(
              icon: expanded
                  ? HugeIcons.strokeRoundedChevronDown
                  : HugeIcons.strokeRoundedChevronUp,
              size: _icon,
              color: colors.textSecondary,
            ),
          ],
        )
        .padding(horizontal: TwSpacing.s3)
        .constrained(height: expanded ? _expandedHeader : collapsedHeight)
        .gestures(behavior: HitTestBehavior.opaque, onTap: onToggle);
  }

  Widget _avatars(AppColors colors) {
    final shown = entries.take(_maxAvatars).toList();
    final width = _avatar + (shown.length - 1) * _avatarOverlap;
    return SizedBox(
      width: width,
      height: _avatar,
      child: Stack(
        children: [
          for (var i = 0; i < shown.length; i++)
            SupermarketLogo(
                  chain: shown[i].store.supermarket,
                  size: _avatarLogo,
                )
                .center()
                .constrained(width: _avatar, height: _avatar)
                .decorated(
                  color: colors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.border, width: _hairline),
                )
                .positioned(left: i * _avatarOverlap),
        ],
      ),
    );
  }

  Widget _row(
    AppColors colors,
    StoreDistance entry, {
    required bool removable,
  }) {
    final store = entry.store;
    return Row(
      spacing: TwSpacing.s3,
      children: [
        SupermarketLogo(chain: store.supermarket, size: _rowLogo),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              store.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: TwFontSize.sm,
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
            fontSize: TwFontSize.xs,
            fontWeight: TwFontWeight.semibold,
          ),
        ),
        if (removable)
          Semantics(
            label: 'Remove ${store.name}',
            button: true,
            child:
                HugeIcon(
                      icon: HugeIcons.strokeRoundedCancel01,
                      size: TwSpacing.s4,
                      color: colors.textSecondary,
                    )
                    .padding(all: TwSpacing.s2)
                    .gestures(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onRemove(store),
                    ),
          ),
      ],
    ).padding(
      left: TwSpacing.s4,
      right: removable ? TwSpacing.s2 : TwSpacing.s4,
      top: TwSpacing.s2,
      bottom: TwSpacing.s2,
    );
  }
}

part of '../stores_map.dart';

class _StoreMarker extends StatelessWidget {
  const _StoreMarker({
    required this.store,
    required this.kilometres,
    required this.selected,
    required this.onTap,
  });

  static const double width = 168;
  static const double height = 104;
  static const double _badge = 38;
  static const double _logo = TwSpacing.s6;
  static const double _tick = TwSpacing.s4;
  static const double _tickIcon = 11;
  static const double _tickOffset = -4;
  static const double _popScale = 0.14;
  static const double _ring = 2.5;
  static const double _maxTickScale = 1.3;
  static const Duration _animation = Duration(milliseconds: 320);

  final StoreLocation store;
  final double kilometres;
  final bool selected;
  final VoidCallback onTap;

  void _handleTap() {
    HapticFeedback.selectionClick();
    onTap();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      spacing: TwSpacing.s1,
      children: [
        Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  store.branch,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: TwFontSize.xs,
                    fontWeight: TwFontWeight.semibold,
                  ),
                ),
                Text(
                  GeoUtil.formatKilometres(kilometres),
                  maxLines: 1,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: TwFontSize.xs,
                    fontWeight: TwFontWeight.medium,
                  ),
                ),
              ],
            )
            .padding(horizontal: TwSpacing.s2_5, vertical: TwSpacing.s1)
            .decorated(
              color: colors.surface,
              borderRadius: BorderRadius.circular(TwRadius.lg),
              border: Border.all(color: colors.border, width: _hairline),
              boxShadow: _panel(colors).boxShadow,
            )
            .gestures(behavior: HitTestBehavior.opaque, onTap: _handleTap),
        TweenAnimationBuilder<double>(
          tween: Tween(end: selected ? 1.0 : 0.0),
          duration: _animation,
          curve: Curves.easeOutBack,
          builder: (context, value, _) {
            final ring = value.clamp(0.0, 1.0);
            return Stack(
              clipBehavior: Clip.none,
              children: [
                SupermarketLogo(chain: store.supermarket, size: _logo)
                    .center()
                    .constrained(width: _badge, height: _badge)
                    .decorated(
                      color: colors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Color.lerp(
                          BrandColors.accent500.withValues(alpha: 0),
                          BrandColors.accent500,
                          ring,
                        )!,
                        width: _ring,
                      ),
                      boxShadow: _panel(colors).boxShadow,
                    )
                    .scale(all: 1 + _popScale * value),
                if (value > 0)
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
                      .scale(all: value.clamp(0.0, _maxTickScale))
                      .positioned(left: _tickOffset, top: _tickOffset),
              ],
            );
          },
        ).gestures(behavior: HitTestBehavior.opaque, onTap: _handleTap),
      ],
    );
  }
}

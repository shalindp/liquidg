part of '../stores_map.dart';

class _StoreMarkerBadge extends StatelessWidget {
  const _StoreMarkerBadge({
    required this.store,
    required this.selected,
    required this.onTap,
  });

  static const double boxSize = 64;
  static const double size = 38;
  static const double _logo = TwSpacing.s6;
  static const double _pinCircle = TwSpacing.s5;
  static const double _pinIcon = 14;
  static const double _pinOffset = -8;
  static const double _popScale = 0.14;
  static const double _ring = 2.5;
  static const Duration _animation = Duration(milliseconds: 320);
  static const String _pinSvg =
      '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none"><path fill-rule="evenodd" d="M13.30 18.88 13.84 18.99 14.03 19.00 14.18 18.99 14.37 18.96 14.54 18.91 14.75 18.83 14.90 18.74 15.02 18.66 15.13 18.56 15.24 18.44 15.36 18.28 15.71 17.70 15.96 17.19 16.10 16.80 16.21 16.40 16.29 16.01 16.34 15.57 16.35 15.19 16.34 14.78 16.20 13.12 16.17 12.34 16.18 12.04 16.22 11.79 16.28 11.61 16.38 11.43 16.50 11.29 16.65 11.15 16.86 10.99 17.11 10.83 17.64 10.52 19.82 9.30 20.13 9.11 20.34 8.96 20.58 8.76 20.76 8.54 20.88 8.30 20.97 7.99 20.99 7.83 21.00 7.68 20.96 7.37 20.85 7.00 20.62 6.39 20.44 5.99 20.21 5.58 19.94 5.20 19.65 4.84 19.33 4.50 19.01 4.22 18.66 3.95 18.29 3.72 17.91 3.51 17.53 3.34 16.97 3.14 16.60 3.04 16.40 3.00 16.22 3.00 16.01 3.03 15.81 3.08 15.61 3.16 15.44 3.26 15.29 3.37 15.15 3.51 14.97 3.75 14.75 4.09 13.46 6.40 13.12 6.97 12.94 7.22 12.77 7.42 12.62 7.56 12.45 7.67 12.31 7.73 12.13 7.77 11.93 7.80 11.67 7.81 10.92 7.78 9.39 7.66 9.01 7.64 8.42 7.66 7.85 7.73 7.48 7.82 7.14 7.92 6.81 8.04 6.49 8.19 6.14 8.38 5.70 8.66 5.50 8.81 5.34 8.98 5.20 9.20 5.08 9.49 5.02 9.74 5.00 10.00 5.04 10.31 5.15 10.85 5.28 11.30 5.42 11.75 5.60 12.22 5.81 12.68 6.04 13.13 6.31 13.61 6.59 14.05 6.91 14.50 7.25 14.93 7.61 15.36 7.47 15.47 2.47 20.47 2.38 20.58 2.28 20.78 2.25 21.00 2.26 21.15 2.34 21.35 2.42 21.48 2.58 21.62 2.71 21.69 2.93 21.75 3.15 21.74 3.35 21.66 3.48 21.58 8.53 16.53 8.64 16.39 9.18 16.85 9.74 17.26 10.32 17.64 10.89 17.97 11.50 18.27 12.10 18.52 12.70 18.72 13.30 18.88Z" fill="currentColor"/></svg>';

  final StoreLocation store;
  final bool selected;
  final VoidCallback onTap;

  void _handleTap() {
    HapticFeedback.selectionClick();
    onTap();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return TweenAnimationBuilder<double>(
      tween: Tween(end: selected ? 1.0 : 0.0),
      duration: _animation,
      curve: Curves.easeOutBack,
      builder: (context, value, _) {
        final ring = value.clamp(0.0, 1.0);
        return Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              SupermarketLogo(chain: store.supermarket, size: _logo)
                  .center()
                  .constrained(width: size, height: size)
                  .decorated(
                    color: colors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Color.lerp(
                        colors.border,
                        BrandColors.accent500,
                        ring,
                      )!,
                      width: selected ? _ring : _hairline,
                    ),
                    boxShadow: _panel(colors).boxShadow,
                  )
                  .scale(all: 1 + _popScale * value),
              if (value > 0)
                Container(
                      width: _pinCircle,
                      height: _pinCircle,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: BrandColors.accent500,
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.string(
                        _pinSvg,
                        width: _pinIcon,
                        height: _pinIcon,
                        colorFilter: ColorFilter.mode(
                          colors.textOnAccent,
                          BlendMode.srcIn,
                        ),
                      ),
                    )
                    .scale(all: value.clamp(0.0, 1.3))
                    .positioned(right: _pinOffset, top: _pinOffset),
            ],
          ),
        );
      },
    ).gestures(behavior: HitTestBehavior.opaque, onTap: _handleTap);
  }
}

class _CalloutLayer extends StatelessWidget {
  const _CalloutLayer({
    required this.entry,
    required this.selected,
    required this.topInset,
    required this.onToggle,
    required this.onOffscreen,
  });

  static const double _edge = TwSpacing.s3;
  static const double _visibleMargin = TwSpacing.s3;
  static const double _gap = 30;
  static const double _estimatedHeight = 150;

  final StoreDistance entry;
  final bool selected;
  final double topInset;
  final VoidCallback onToggle;
  final VoidCallback onOffscreen;

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);
    final size = camera.nonRotatedSize;
    final anchor = camera.latLngToScreenOffset(entry.store.position);
    final visible = Rect.fromLTRB(
      _visibleMargin,
      topInset,
      size.width - _visibleMargin,
      size.height,
    );
    if (!visible.contains(anchor)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => onOffscreen());
      return const SizedBox.shrink();
    }
    final width = math.min(_StoreCallout.width, size.width - 2 * _edge);
    final left = (anchor.dx - width / 2).clamp(
      _edge,
      size.width - width - _edge,
    );
    final caretX = (anchor.dx - left).clamp(
      _StoreCallout.caretInset,
      width - _StoreCallout.caretInset,
    );
    final below = anchor.dy - _gap - _estimatedHeight < topInset;
    final callout = _StoreCallout(
      store: entry.store,
      kilometres: entry.kilometres,
      selected: selected,
      calloutWidth: width,
      caretX: caretX.toDouble(),
      below: below,
      onToggle: onToggle,
    );
    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (below)
          Positioned(
            left: left.toDouble(),
            top: anchor.dy + _gap,
            child: callout,
          )
        else
          Positioned(
            left: left.toDouble(),
            bottom: size.height - anchor.dy + _gap,
            child: callout,
          ),
      ],
    );
  }
}

class _StoreCallout extends StatelessWidget {
  const _StoreCallout({
    required this.store,
    required this.kilometres,
    required this.selected,
    required this.calloutWidth,
    required this.caretX,
    required this.below,
    required this.onToggle,
  });

  static const double width = 240;
  static const double caretInset = TwSpacing.s6;
  static const double _caretSide = 11;
  static const double _eighthTurn = 0.7853981633974483;
  static const Duration _animation = Duration(milliseconds: 180);

  final StoreLocation store;
  final double kilometres;
  final bool selected;
  final double calloutWidth;
  final double caretX;
  final bool below;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: _animation,
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.scale(
          scale: 0.92 + 0.08 * t,
          alignment: Alignment((caretX / calloutWidth) * 2 - 1, below ? -1 : 1),
          child: child,
        ),
      ),
      child: SizedBox(
        width: calloutWidth,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            _card(colors),
            Positioned(
              left: caretX - _caretSide / 2,
              top: below ? -_caretSide / 2 : null,
              bottom: below ? null : -_caretSide / 2,
              child: Transform.rotate(
                angle: _eighthTurn,
                child: SizedBox(width: _caretSide, height: _caretSide)
                    .decorated(
                      color: colors.surface,
                      border: Border(
                        top: below
                            ? BorderSide(color: colors.border, width: _hairline)
                            : BorderSide.none,
                        left: below
                            ? BorderSide(color: colors.border, width: _hairline)
                            : BorderSide.none,
                        right: below
                            ? BorderSide.none
                            : BorderSide(
                                color: colors.border,
                                width: _hairline,
                              ),
                        bottom: below
                            ? BorderSide.none
                            : BorderSide(
                                color: colors.border,
                                width: _hairline,
                              ),
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(AppColors colors) {
    return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: TwSpacing.s3,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: TwSpacing.s1,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.supermarket.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: TwFontSize.xs,
                        fontWeight: TwFontWeight.medium,
                      ),
                    ),
                    Text(
                      store.branch,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: TwFontSize.base,
                        fontWeight: TwFontWeight.semibold,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
                Row(
                  spacing: TwSpacing.s1_5,
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedNavigation03,
                      size: TwSpacing.s4,
                      color: colors.textSecondary,
                    ),
                    Text.rich(
                      TextSpan(
                        text: GeoUtil.formatKilometres(kilometres),
                        style: const TextStyle(
                          fontWeight: TwFontWeight.semibold,
                        ),
                        children: const [
                          TextSpan(
                            text: ' from you',
                            style: TextStyle(fontWeight: TwFontWeight.normal),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: TwFontSize.sm,
                      ),
                    ).flexible(),
                  ],
                ),
              ],
            ),
            AnimatedSwitcher(
              duration: _animation,
              child: FilledButton(
                key: ValueKey(selected),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  onToggle();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: selected
                      ? colors.surfaceMuted
                      : BrandColors.accent500,
                  foregroundColor: selected
                      ? colors.danger
                      : colors.textOnAccent,
                  minimumSize: const Size.fromHeight(TwSpacing.s11),
                  shape: const StadiumBorder(),
                  textStyle: const TextStyle(
                    fontSize: TwFontSize.sm,
                    fontWeight: TwFontWeight.semibold,
                  ),
                ),
                child: Text(selected ? 'Not shopping here' : 'Shop here'),
              ),
            ),
          ],
        )
        .padding(all: TwSpacing.s3)
        .decorated(
          color: colors.surface,
          borderRadius: BorderRadius.circular(TwRadius.xl2),
          border: Border.all(color: colors.border, width: _hairline),
          boxShadow: [
            BoxShadow(
              color: colors.textPrimary.withValues(alpha: 0.14),
              blurRadius: TwSpacing.s3,
            ),
          ],
        );
  }
}

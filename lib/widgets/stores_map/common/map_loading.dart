part of '../stores_map.dart';

class _MapLoading extends StatefulWidget {
  const _MapLoading();

  @override
  State<_MapLoading> createState() => _MapLoadingState();
}

class _MapLoadingState extends State<_MapLoading>
    with SingleTickerProviderStateMixin {
  static const Duration _period = Duration(milliseconds: 2400);
  static const double _area = 168;
  static const double _dot = TwSpacing.s5;
  static const double _dotBorder = 3;
  static const int _rings = 3;
  static const double _ringAlpha = 0.4;
  static const double _fillAlpha = 0.12;
  static const double _ringWidth = 1.5;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _period,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (still) {
      _controller.value = 0.35;
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: _area,
          height: _area,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => Stack(
              alignment: Alignment.center,
              children: [
                for (var i = 0; i < _rings; i++) _ring(colors, i),
                const SizedBox(width: _dot, height: _dot).decorated(
                  color: BrandColors.accent500,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.surface, width: _dotBorder),
                  boxShadow: [
                    BoxShadow(
                      color: colors.textPrimary.withValues(alpha: 0.2),
                      blurRadius: TwSpacing.s1,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: TwSpacing.s2),
        Text(
          'Finding stores near you',
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: TwFontSize.sm,
            fontWeight: TwFontWeight.medium,
          ),
        ),
      ],
    ).center();
  }

  Widget _ring(AppColors colors, int index) {
    final t = (_controller.value + index / _rings) % 1;
    final eased = Curves.easeOutCubic.transform(t);
    final size = _dot + (_area - _dot) * eased;
    final fade = 1 - t;
    return SizedBox(width: size, height: size).decorated(
      shape: BoxShape.circle,
      color: BrandColors.accent500.withValues(alpha: _fillAlpha * fade),
      border: Border.all(
        color: BrandColors.accent500.withValues(alpha: _ringAlpha * fade),
        width: _ringWidth,
      ),
    );
  }
}

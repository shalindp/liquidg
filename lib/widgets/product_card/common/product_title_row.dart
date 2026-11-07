part of '../product_card.dart';

class _TitleRow extends StatelessWidget {
  const _TitleRow({
    required this.name,
    required this.favourite,
    required this.onFavourite,
  });

  final String name;
  final Signal<bool> favourite;
  final VoidCallback onFavourite;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: TwFontSize.sm,
            fontWeight: TwFontWeight.medium,
          ),
        ).expanded(),
        _FavouriteIcon(favourite: favourite)
            .gestures(onTap: onFavourite, behavior: HitTestBehavior.opaque),
      ],
    );
  }
}

class _FavouriteIcon extends StatefulWidget {
  const _FavouriteIcon({required this.favourite});

  final Signal<bool> favourite;

  @override
  State<_FavouriteIcon> createState() => _FavouriteIconState();
}

class _FavouriteIconState extends State<_FavouriteIcon>
    with TickerProviderStateMixin {
  static const _spring = SpringDescription(
    mass: 1,
    stiffness: 300,
    damping: 15,
  );
  static const double _box = TwSpacing.s10;

  late final _pop = AnimationController.unbounded(vsync: this, value: 1);
  late final _burst = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );
  late final VoidCallback _unsubscribe;
  bool _primed = false;

  @override
  void initState() {
    super.initState();
    _unsubscribe = widget.favourite.subscribe((on) {
      if (_primed) _play(on);
      _primed = true;
    });
  }

  void _play(bool on) {
    final from = on ? 0.3 : 0.8;
    _pop.value = from;
    _pop.animateWith(SpringSimulation(_spring, from, 1, 0));
    if (on) _burst.forward(from: 0);
  }

  @override
  void dispose() {
    _unsubscribe();
    _pop.dispose();
    _burst.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: TwSpacing.s5,
      height: TwSpacing.s5,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          IgnorePointer(
            child: CustomPaint(
              size: const Size.square(_box),
              painter: _BurstPainter(
                progress: _burst,
                colors: [colors.danger, colors.warning],
              ),
            ),
          ),
          SignalBuilder(
            builder: (context) {
              final on = widget.favourite.value;
              return AnimatedBuilder(
                animation: _pop,
                builder: (context, child) =>
                    Transform.scale(scale: _pop.value, child: child),
                child: on
                    ? SvgPicture.asset(
                        'assets/icons/favourite.svg',
                        width: TwSpacing.s5,
                        height: TwSpacing.s5,
                        colorFilter: ColorFilter.mode(
                          colors.danger,
                          BlendMode.srcIn,
                        ),
                      )
                    : HugeIcon(
                        icon: HugeIcons.strokeRoundedFavourite,
                        color: colors.textSecondary.withValues(alpha: 0.5),
                        size: TwSpacing.s5,
                      ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  _BurstPainter({required this.progress, required this.colors})
    : super(repaint: progress);

  static const int _dots = 8;

  final Animation<double> progress;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final t = Curves.easeOutCubic.transform(progress.value);
    if (progress.value == 0 || progress.value == 1) return;
    final center = size.center(Offset.zero);
    final reach = size.width / 2;

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = lerpDouble(3, 0, t)!
      ..color = colors.first.withValues(alpha: 1 - t);
    canvas.drawCircle(center, lerpDouble(reach * 0.3, reach * 0.85, t)!, ring);

    final p = ((progress.value - 0.15) / 0.85).clamp(0.0, 1.0);
    final dotT = Curves.easeOutCubic.transform(p);
    for (var i = 0; i < _dots; i++) {
      final angle = -math.pi / 2 + i * 2 * math.pi / _dots;
      final distance = lerpDouble(reach * 0.55, reach * 1.15, dotT)!;
      final paint = Paint()
        ..color = colors[i % colors.length].withValues(alpha: 1 - p);
      canvas.drawCircle(
        center + Offset(math.cos(angle), math.sin(angle)) * distance,
        lerpDouble(2.2, 0, p)!,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_BurstPainter oldDelegate) => oldDelegate.colors != colors;
}

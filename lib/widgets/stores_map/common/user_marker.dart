part of '../stores_map.dart';

class _UserMarker extends StatelessWidget {
  const _UserMarker();

  static const double size = TwSpacing.s11;
  static const double _dot = TwSpacing.s5;
  static const double _dotBorder = 3;
  static const double _haloAlpha = 0.2;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return const SizedBox(width: _dot, height: _dot)
        .decorated(
          color: colors.accent,
          shape: BoxShape.circle,
          border: Border.all(color: colors.surface, width: _dotBorder),
          boxShadow: [
            BoxShadow(
              color: colors.textPrimary.withValues(alpha: 0.2),
              blurRadius: TwSpacing.s1,
            ),
          ],
        )
        .center()
        .decorated(
          color: colors.accent.withValues(alpha: _haloAlpha),
          shape: BoxShape.circle,
        );
  }
}

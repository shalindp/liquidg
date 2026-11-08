part of '../stores_map.dart';

class _RecenterButton extends StatelessWidget {
  const _RecenterButton({required this.onTap});

  static const double size = TwSpacing.s12;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label: 'Recenter on my location',
      button: true,
      child:
          HugeIcon(
                icon: HugeIcons.strokeRoundedGps01,
                color: colors.textPrimary,
                size: TwSpacing.s6,
              )
              .center()
              .constrained(width: size, height: size)
              .decorated(
                color: colors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: colors.border, width: _hairline),
                boxShadow: _panel(colors).boxShadow,
              )
              .gestures(behavior: HitTestBehavior.opaque, onTap: onTap),
    );
  }
}

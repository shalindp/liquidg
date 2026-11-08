part of '../stores_map.dart';

class _RecenterButton extends StatelessWidget {
  const _RecenterButton({required this.onTap});

  static const double size = TwSpacing.s12;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Recenter on my location',
      button: true,
      child: AppGlassButton(
        size: size,
        folded: true,
        onPressed: onTap,
        child: HugeIcon(
          icon: HugeIcons.strokeRoundedGps01,
          color: context.colors.textPrimary,
          size: TwSpacing.s6,
        ),
      ),
    );
  }
}

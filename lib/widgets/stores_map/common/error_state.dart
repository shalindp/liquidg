part of '../stores_map.dart';

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.status, required this.onRetry});

  final StoresMapStatus status;
  final VoidCallback onRetry;

  (String, String) get _copy => switch (status) {
    StoresMapStatus.servicesDisabled => (
      'Location is turned off',
      'Turn on location services so we can show the stores near you.',
    ),
    StoresMapStatus.permissionDenied => (
      'Location access needed',
      'Allow location access in your device settings to see nearby stores.',
    ),
    _ => ('Couldn’t find your location', 'Check your signal and try again.'),
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (title, body) = _copy;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: TwSpacing.s4,
      children: [
        HugeIcon(
          icon: HugeIcons.strokeRoundedMapPinpoint01,
          color: colors.textSecondary,
          size: TwSpacing.s16,
        ),
        Column(
          spacing: TwSpacing.s2,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: TwFontSize.lg,
                fontWeight: TwFontWeight.semibold,
              ),
            ),
            Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: TwFontSize.sm,
              ),
            ),
          ],
        ),
        FilledButton(
          onPressed: onRetry,
          style: FilledButton.styleFrom(
            backgroundColor: BrandColors.accent500,
            foregroundColor: colors.textOnAccent,
            minimumSize: const Size(TwSpacing.s24, TwSpacing.s11),
            padding: const EdgeInsets.symmetric(horizontal: TwSpacing.s8),
            shape: const StadiumBorder(),
            textStyle: const TextStyle(
              fontSize: TwFontSize.sm,
              fontWeight: TwFontWeight.medium,
            ),
          ),
          child: const Text('Try again'),
        ),
      ],
    ).padding(horizontal: TwSpacing.s8);
  }
}

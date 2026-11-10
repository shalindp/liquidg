part of '../stores_map.dart';

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.status, required this.onRetry});

  final StoresMapStatus status;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final blocked = status == StoresMapStatus.permissionDenied;
    final (title, message) = switch (status) {
      StoresMapStatus.servicesDisabled => (
        'Location is turned off',
        'Turn on location services so we can show the stores near you.',
      ),
      StoresMapStatus.permissionDenied => (
        DevicePermission.location.blockedTitle,
        DevicePermission.location.blockedMessage,
      ),
      _ => (
        'Couldn\u2019t find your location',
        'Check your signal and try again.',
      ),
    };
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: TwSpacing.s6),
        child: NoPermsView(
          icon: HugeIcons.strokeRoundedMapPinpoint01,
          title: title,
          message: message,
          primaryLabel: blocked ? 'Open Settings' : 'Try again',
          onPrimary: blocked
              ? () => getIt<DevicePermissionService>().openSettings()
              : onRetry,
        ),
      ),
    );
  }
}

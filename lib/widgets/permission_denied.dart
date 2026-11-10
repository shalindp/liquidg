import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:styled_widget/styled_widget.dart';

import '../service_locator.dart';
import '../services/device_permission_service.dart';
import '../theme/theme.dart';
import 'no_perms_view.dart';

Future<void> showPermissionDeniedSheet(
  BuildContext context, {
  required List<List<dynamic>> icon,
  required String title,
  required String message,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    showDragHandle: true,
    builder: (sheetContext) =>
        NoPermsView(
          icon: icon,
          title: title,
          message: message,
          primaryLabel: 'Open Settings',
          onPrimary: () => getIt<DevicePermissionService>().openSettings(),
          secondaryLabel: 'Not now',
          onSecondary: () => Navigator.of(sheetContext).pop(),
        ).padding(
          left: TwSpacing.s6,
          right: TwSpacing.s6,
          top: TwSpacing.s2,
          bottom: TwSpacing.s4 + MediaQuery.viewPaddingOf(sheetContext).bottom,
        ),
  );
}

extension DevicePermissionCopy on DevicePermission {
  List<List<dynamic>> get icon => switch (this) {
    DevicePermission.camera => HugeIcons.strokeRoundedCamera01,
    DevicePermission.location => HugeIcons.strokeRoundedMapPinpoint01,
  };

  String get blockedTitle => switch (this) {
    DevicePermission.camera => 'Camera access needed',
    DevicePermission.location => 'Location access needed',
  };

  String get blockedMessage => switch (this) {
    DevicePermission.camera =>
      'Turn on camera access in Settings so you can scan product barcodes.',
    DevicePermission.location =>
      'Allow location access in your device settings to see nearby stores.',
  };
}

Future<bool> ensureDevicePermission(
  BuildContext context,
  DevicePermission permission,
) async {
  final outcome = await getIt<DevicePermissionService>().ensure(permission);
  if (outcome == PermissionOutcome.blocked && context.mounted) {
    await showPermissionDeniedSheet(
      context,
      icon: permission.icon,
      title: permission.blockedTitle,
      message: permission.blockedMessage,
    );
  }
  return outcome == PermissionOutcome.granted;
}

import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:signals_flutter/signals_flutter.dart';

enum DevicePermission {
  camera(ph.Permission.camera),
  location(ph.Permission.locationWhenInUse);

  const DevicePermission(this.permission);

  final ph.Permission permission;
}

enum PermissionOutcome { granted, denied, blocked }

enum DevicePermissionStatus {
  unknown,
  granted,
  limited,
  denied,
  permanentlyDenied,
  restricted;

  bool get isGranted =>
      this == DevicePermissionStatus.granted ||
      this == DevicePermissionStatus.limited;

  bool get canRequest =>
      this == DevicePermissionStatus.unknown ||
      this == DevicePermissionStatus.denied;

  bool get needsSettings =>
      this == DevicePermissionStatus.permanentlyDenied ||
      this == DevicePermissionStatus.restricted;
}

class DevicePermissionService with WidgetsBindingObserver {
  DevicePermissionService() {
    WidgetsBinding.instance.addObserver(this);
  }

  static const Duration noDialogWindow = Duration(milliseconds: 350);

  final statuses = signal<Map<DevicePermission, DevicePermissionStatus>>({
    for (final permission in DevicePermission.values)
      permission: DevicePermissionStatus.unknown,
  });

  DevicePermissionStatus statusOf(DevicePermission permission) =>
      statuses.value[permission] ?? DevicePermissionStatus.unknown;

  ReadonlySignal<DevicePermissionStatus> watch(DevicePermission permission) =>
      computed(() => statusOf(permission));

  Future<void> refreshAll() async {
    await Future.wait([
      for (final permission in DevicePermission.values) refresh(permission),
    ]);
  }

  Future<DevicePermissionStatus> refresh(DevicePermission permission) async {
    final status = _map(await permission.permission.status);
    _store(permission, status);
    return status;
  }

  Future<DevicePermissionStatus> request(DevicePermission permission) async {
    final current = await refresh(permission);
    if (!current.canRequest) return current;
    return _prompt(permission);
  }

  Future<PermissionOutcome> ensure(DevicePermission permission) async {
    final current = await refresh(permission);
    if (current.isGranted) return PermissionOutcome.granted;
    if (current.needsSettings) return PermissionOutcome.blocked;
    final stopwatch = Stopwatch()..start();
    final status = await _prompt(permission);
    stopwatch.stop();
    if (status.isGranted) return PermissionOutcome.granted;
    if (status.needsSettings && stopwatch.elapsed < noDialogWindow) {
      return PermissionOutcome.blocked;
    }
    return PermissionOutcome.denied;
  }

  Future<DevicePermissionStatus> _prompt(DevicePermission permission) async {
    final status = _map(await permission.permission.request());
    _store(permission, status);
    return status;
  }

  Future<bool> openSettings() => ph.openAppSettings();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) refreshAll();
  }

  void _store(DevicePermission permission, DevicePermissionStatus status) {
    if (statuses.value[permission] == status) return;
    statuses.value = {...statuses.value, permission: status};
  }

  DevicePermissionStatus _map(ph.PermissionStatus status) => switch (status) {
    ph.PermissionStatus.granted => DevicePermissionStatus.granted,
    ph.PermissionStatus.limited => DevicePermissionStatus.limited,
    ph.PermissionStatus.denied => DevicePermissionStatus.denied,
    ph.PermissionStatus.permanentlyDenied =>
      DevicePermissionStatus.permanentlyDenied,
    ph.PermissionStatus.restricted => DevicePermissionStatus.restricted,
    ph.PermissionStatus.provisional => DevicePermissionStatus.granted,
  };

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    statuses.dispose();
  }
}

import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

enum LocationFailure { permissionDenied, servicesDisabled, unavailable }

class LocationException implements Exception {
  const LocationException(this.failure);

  final LocationFailure failure;

  @override
  String toString() => 'LocationException(${failure.name})';
}

class LocationService {
  LocationService({Location? location}) : _location = location ?? Location();

  static const Duration _timeout = Duration(seconds: 15);

  final Location _location;

  Future<LatLng> currentPosition() async {
    try {
      await _ensurePermission();
      await _ensureServiceEnabled();
      final data = await _location.getLocation().timeout(_timeout);
      return LatLng(data.latitude, data.longitude);
    } on LocationException {
      rethrow;
    } on PlatformException {
      throw const LocationException(LocationFailure.unavailable);
    } on Exception {
      throw const LocationException(LocationFailure.unavailable);
    }
  }

  Future<LatLng?> cachedPosition() async {
    try {
      await _ensurePermission();
      await _ensureServiceEnabled();
      final data = await _location.getLastKnownLocation();
      if (data == null) return null;
      return LatLng(data.latitude, data.longitude);
    } on LocationException {
      rethrow;
    } on PlatformException {
      return null;
    }
  }

  Future<void> _ensurePermission() async {
    var status = await _location.hasPermission();
    if (status == PermissionStatus.denied) {
      status = await _location.requestPermission();
    }
    final granted =
        status == PermissionStatus.granted ||
        status == PermissionStatus.grantedLimited;
    if (!granted) {
      throw const LocationException(LocationFailure.permissionDenied);
    }
  }

  Future<void> _ensureServiceEnabled() async {
    if (await _location.serviceEnabled()) return;
    if (!await _location.requestService()) {
      throw const LocationException(LocationFailure.servicesDisabled);
    }
  }
}

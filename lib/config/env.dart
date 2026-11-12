import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

class Env {
  const Env._(this.apiBaseUrl, this.devLocation, this.defaultStoreIds);

  final String apiBaseUrl;
  final LatLng? devLocation;
  final List<int> defaultStoreIds;

  static Future<Env> load() async {
    final raw = await rootBundle.loadString('env.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return Env._(
      json['API_BASE_URL'] as String,
      _parseLocation(json['DEV_LOCATION'] as String?),
      _parseIds(json['DEFAULT_STORE_IDS'] as String?),
    );
  }

  static List<int> _parseIds(String? value) {
    if (value == null) return const [];
    return [for (final part in value.split(',')) ?int.tryParse(part.trim())];
  }

  static LatLng? _parseLocation(String? value) {
    if (value == null) return null;
    final parts = value.split(',');
    if (parts.length != 2) return null;
    final latitude = double.tryParse(parts[0].trim());
    final longitude = double.tryParse(parts[1].trim());
    if (latitude == null || longitude == null) return null;
    return LatLng(latitude, longitude);
  }
}

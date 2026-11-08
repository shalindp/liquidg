import 'package:latlong2/latlong.dart';

import 'supermarket.dart';

class StoreLocation {
  const StoreLocation({
    required this.id,
    required this.supermarket,
    required this.name,
    required this.position,
  });

  final int id;
  final Supermarket supermarket;
  final String name;
  final LatLng position;

  String get branch {
    final stripped = name
        .replaceAll(supermarket.namePattern, '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return stripped.isEmpty ? name : stripped;
  }

  @override
  bool operator ==(Object other) =>
      other is StoreLocation &&
      other.id == id &&
      other.supermarket == supermarket &&
      other.name == name &&
      other.position == position;

  @override
  int get hashCode => Object.hash(id, supermarket, name, position);
}

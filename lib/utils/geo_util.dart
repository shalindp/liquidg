import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class GeoUtil {
  GeoUtil._();

  static const Distance _distance = Distance(
    roundResult: false,
    calculator: Haversine(),
  );

  static const double _north = 0;
  static const double _east = 90;
  static const double _south = 180;
  static const double _west = -90;
  static const int _fractionDigits = 1;

  static double kilometres(LatLng from, LatLng to) =>
      _distance.as(LengthUnit.Kilometer, from, to);

  static String formatKilometres(double kilometres) =>
      '${kilometres.toStringAsFixed(_fractionDigits)} km';

  static LatLngBounds boundsAround(LatLng center, double radiusMeters) =>
      LatLngBounds.fromPoints([
        _distance.offset(center, radiusMeters, _north),
        _distance.offset(center, radiusMeters, _east),
        _distance.offset(center, radiusMeters, _south),
        _distance.offset(center, radiusMeters, _west),
      ]);
}

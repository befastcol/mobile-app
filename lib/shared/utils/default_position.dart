import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

LatLng defaultLatLng = const LatLng(19.243373669401056, -103.72850900850291);

Position defaultPosition = Position(
  timestamp: DateTime.now(),
  altitudeAccuracy: 0.0,
  headingAccuracy: 0.0,
  latitude: defaultLatLng.latitude,
  longitude: defaultLatLng.longitude,
  accuracy: 0.0,
  altitude: 0.0,
  heading: 0.0,
  speed: 0.0,
  speedAccuracy: 0.0,
);

import 'package:be_fast/shared/utils/default_position.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationHelper {
  static bool _hasRequestedCurrentPosition = false;

  static Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return defaultPosition;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return defaultPosition;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return defaultPosition;
    }

    if (_hasRequestedCurrentPosition) {
      Position? lastPosition = await Geolocator.getLastKnownPosition();
      if (lastPosition != null) {
        return lastPosition;
      }
    }

    _hasRequestedCurrentPosition = true;
    return await Geolocator.getCurrentPosition();
  }

  static Future<Placemark> getPlacemarks(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      return placemarks[0];
    } catch (e) {
      throw Exception('Failed to get place name: $e');
    }
  }
}

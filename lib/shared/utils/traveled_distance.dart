import 'package:be_fast/shared/utils/location_helper.dart';
import 'package:geolocator/geolocator.dart';

class DistanceResult {
  final double distance;
  final Position position;

  DistanceResult({required this.distance, required this.position});
}

Future calculateTraveledDistance(Position? lastPosition) async {
  try {
    Position position = await LocationHelper.determinePosition();

    double distance = Geolocator.distanceBetween(
      lastPosition?.latitude ?? 0,
      lastPosition?.longitude ?? 0,
      position.latitude,
      position.longitude,
    );

    return DistanceResult(distance: distance, position: position);
  } catch (e) {
    return DistanceResult(distance: 0, position: lastPosition!);
  }
}

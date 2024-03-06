import 'package:geolocator/geolocator.dart';

class DistanceResult {
  final double distance;
  final Position position;

  DistanceResult({required this.distance, required this.position});
}

Future calculateTraveledDistance(Position? lastPosition) async {
  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);

  double distance = Geolocator.distanceBetween(
    lastPosition?.latitude ?? 0,
    lastPosition?.longitude ?? 0,
    position.latitude,
    position.longitude,
  );

  return DistanceResult(distance: distance, position: position);
}

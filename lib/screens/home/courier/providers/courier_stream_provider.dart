import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:be_fast/api/google_maps.dart';
import 'package:be_fast/api/users.dart';
import 'package:be_fast/models/custom/custom.dart';
import 'package:be_fast/models/delivery.dart';
import 'package:be_fast/screens/home/courier/providers/courier_map_provider.dart';
import 'package:be_fast/shared/utils/location_helper.dart';
import 'package:be_fast/shared/utils/traveled_distance.dart';
import 'package:be_fast/shared/utils/socket_service.dart';
import 'package:be_fast/shared/utils/user_session.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class CourierStreamProvider with ChangeNotifier {
  final CourierMapProvider _courierMapProvider;

  DeliveryModel? _delivery;
  Timer? _timer;
  Position? _lastPosition;
  final SocketService _socketService = SocketService();
  bool _serviceFound = false;
  bool _serviceAccepted = false;

  DeliveryModel? get delivery => _delivery;
  Timer? get timer => _timer;
  Position? get lastPosition => _lastPosition;

  bool get serviceFound => _serviceFound;
  bool get serviceAccepted => _serviceAccepted;

  CourierStreamProvider(this._courierMapProvider) {
    _initSocket();
    _initCurrentLocation();
    _initTimerStream();
    _subscribeToDeliveryUpdates();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _socketService.disconnect();
    _socketService.clearListeners();
    super.dispose();
  }

  void _initSocket() {
    _socketService.initSocket();
    notifyListeners();
  }

  void _initTimerStream() {
    const duration = Duration(seconds: 1);
    _timer = Timer.periodic(duration, (Timer t) async {
      DistanceResult result = await calculateTraveledDistance(_lastPosition);

      if (result.distance > 10) {
        _lastPosition = result.position;
        _courierMapProvider.updateMarker(result.position);
        _courierMapProvider.animateCamera(result.position);
        _emitLocationUpdate(result.position);
        notifyListeners();
      }
    });
  }

  Future _emitLocationUpdate(Position position) async {
    try {
      String? courierId = await UserSession.getUserId();
      _socketService.emit('updateLocation', {
        'courierId': courierId,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'deliveryId': delivery?.id
      });
    } catch (e) {
      debugPrint('Error sending location update: $e');
    }
  }

  Future _subscribeToDeliveryUpdates() async {
    String? courierId = await UserSession.getUserId();
    AudioPlayer player = AudioPlayer();

    _socketService.on("$courierId", (deliveryDetails) async {
      await player.play(AssetSource('sounds/notification_sound.wav'));

      if (deliveryDetails is Map<String, dynamic>) {
        _delivery = DeliveryModel.fromJson(deliveryDetails);
        _serviceFound = true;
        notifyListeners();
      }
    });
  }

  Future _initCurrentLocation() async {
    try {
      String? courierId = await UserSession.getUserId();
      Position position = await LocationHelper.determinePosition();

      await UsersAPI.saveUserCurrentLocation(
          userId: courierId, currentLocation: position);
    } catch (e) {
      debugPrint('Error sending location update: $e');
    }
  }

  Future acceptService(BuildContext context) async {
    _serviceAccepted = true;
    _serviceFound = false;
    notifyListeners();

    try {
      CourierMapProvider courierMapProvider =
          Provider.of<CourierMapProvider>(context, listen: false);

      String? courierId = await UserSession.getUserId();
      _socketService.emit("serviceAccepted", {
        "courierId": courierId,
        "status": 'in_progress',
        "deliveryId": delivery?.id
      });

      Position position = await LocationHelper.determinePosition();

      RouteDetails originRoute = await GoogleMapsAPI().getRouteCoordinates(
          Point(coordinates: [position.longitude, position.latitude]),
          delivery!.origin);

      courierMapProvider.addPolylines(Polyline(
        polylineId: const PolylineId('current_to_origin'),
        points: originRoute.polylinePoints,
        color: Colors.blueAccent,
        width: 8,
      ));

      RouteDetails destinationRoute = await GoogleMapsAPI()
          .getRouteCoordinates(_delivery!.origin, _delivery!.destination);

      courierMapProvider.addPolylines(Polyline(
        polylineId: const PolylineId('origin_to_destination'),
        points: destinationRoute.polylinePoints,
        color: Colors.redAccent,
        width: 8,
      ));
      courierMapProvider.updateMarkers(Marker(
          markerId: const MarkerId('origin'),
          icon: BitmapDescriptor.defaultMarkerWithHue(200),
          position: LatLng(delivery?.origin.coordinates[1] ?? 0,
              delivery?.origin.coordinates[0] ?? 0)));

      courierMapProvider.updateMarkers(Marker(
          markerId: const MarkerId('destination'),
          position: LatLng(delivery?.destination.coordinates[1] ?? 0,
              delivery?.destination.coordinates[0] ?? 0)));
    } catch (e) {
      debugPrint("$e");
    }
  }
}

import 'dart:async';
import 'dart:convert';
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
import 'package:shared_preferences/shared_preferences.dart';

class CourierStreamProvider with ChangeNotifier {
  final CourierMapProvider _courierMapProvider;

  DeliveryModel? _delivery;
  Timer? _timer;
  DateTime? _deadline;
  Position? _lastPosition;
  final SocketService _socketService = SocketService();
  bool _serviceFound = false;
  bool _serviceAccepted = false;

  bool _isAcceptingService = false;
  bool _isEndingService = false;

  DeliveryModel? get delivery => _delivery;
  Timer? get timer => _timer;
  DateTime? get deadline => _deadline;
  Position? get lastPosition => _lastPosition;

  bool get serviceFound => _serviceFound;
  bool get serviceAccepted => _serviceAccepted;

  bool get isAcceptingService => _isAcceptingService;
  bool get isEndingService => _isEndingService;

  CourierStreamProvider(this._courierMapProvider) {
    _initSocket();
    _initCurrentLocation();
    _initTimerStream();
    _subscribeToDeliveryUpdates();
    _checkIfCourierIsBusy();
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

  Future _checkIfCourierIsBusy() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? deliveryInfoJson = prefs.getString('deliveryInfo');

    if (deliveryInfoJson == null || deliveryInfoJson.isEmpty) return;

    try {
      Map<String, dynamic> deliveryData = json.decode(deliveryInfoJson);
      _delivery = DeliveryModel.fromJson(deliveryData);
      await _updateCourierMap();
      updateServiceIsAccepted();
    } catch (e) {
      debugPrint("Error parsing delivery info: $e");
    }
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

    _socketService.emit("joinCourierRoom", {"courierId": courierId});
    _socketService.on("deliveryFound", (data) async {
      await player.play(AssetSource('sounds/notification_sound.wav'));

      if (data is Map<String, dynamic>) {
        _deadline = DateTime.parse(data['deadline']);
        _delivery = DeliveryModel.fromJson(data['deliveryInfo']);
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
    try {
      _isAcceptingService = true;
      notifyListeners();

      await _storeDeliveryDetails();
      await _updateCourierMap();
      await _emitServiceAccepted();

      updateServiceIsAccepted();
    } finally {
      _isAcceptingService = false;
      notifyListeners();
    }
  }

  Future endService() async {
    _isEndingService = true;
    notifyListeners();

    try {
      String? courierId = await UserSession.getUserId();
      _socketService.emit("serviceFinished",
          {"courierId": courierId, "deliveryId": delivery?.id});

      await _resetDeliveryDetails();
    } finally {
      _isEndingService = false;
      _resetState();
    }
  }

  void _resetState() {
    _serviceAccepted = false;
    _serviceFound = false;
    _courierMapProvider.resetState();
    notifyListeners();
  }

  Future _storeDeliveryDetails() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('deliveryInfo', json.encode(_delivery?.toJson()));
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future _resetDeliveryDetails() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString('deliveryInfo', '');
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future _updateCourierMap() async {
    try {
      Position position = await LocationHelper.determinePosition();

      RouteDetails originRoute = await GoogleMapsAPI().getRouteCoordinates(
          Point(coordinates: [position.longitude, position.latitude]),
          delivery!.origin);

      _courierMapProvider.addPolylines(Polyline(
        polylineId: const PolylineId('current_to_origin'),
        points: originRoute.polylinePoints,
        color: Colors.blueAccent,
        width: 8,
      ));

      RouteDetails destinationRoute = await GoogleMapsAPI()
          .getRouteCoordinates(_delivery!.origin, _delivery!.destination);

      _courierMapProvider.addPolylines(Polyline(
        polylineId: const PolylineId('origin_to_destination'),
        points: destinationRoute.polylinePoints,
        color: Colors.redAccent,
        width: 8,
      ));
      _courierMapProvider.updateMarkers(Marker(
          markerId: const MarkerId('origin'),
          icon: BitmapDescriptor.defaultMarkerWithHue(200),
          position: LatLng(delivery?.origin.coordinates[1] ?? 0,
              delivery?.origin.coordinates[0] ?? 0)));

      _courierMapProvider.updateMarkers(Marker(
          markerId: const MarkerId('destination'),
          position: LatLng(delivery?.destination.coordinates[1] ?? 0,
              delivery?.destination.coordinates[0] ?? 0)));
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future _emitServiceAccepted() async {
    try {
      String? courierId = await UserSession.getUserId();
      _socketService.emit("serviceAccepted",
          {"courierId": courierId, "deliveryId": delivery?.id});
    } catch (e) {
      debugPrint("$e");
    }
  }

  void updateServiceIsAccepted() {
    _serviceAccepted = true;
    _serviceFound = false;
    notifyListeners();
  }
}

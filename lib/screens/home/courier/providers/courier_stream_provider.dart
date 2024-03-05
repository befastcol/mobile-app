import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:be_fast/screens/home/courier/providers/courier_map_provider.dart';
import 'package:be_fast/utils/traveled_distance.dart';
import 'package:be_fast/utils/socket_service.dart';
import 'package:be_fast/utils/user_session.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class CourierStreamProvider with ChangeNotifier {
  Timer? _timer;
  Position? _lastPosition;
  final SocketService _socketService = SocketService();
  bool _serviceFound = false;

  Timer? get timer => _timer;
  Position? get lastPosition => _lastPosition;
  bool get serviceFound => _serviceFound;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void initSocket() {
    _socketService.initSocket();
  }

  void initTimerStream(BuildContext context) {
    CourierMapProvider courierMapProvider =
        Provider.of<CourierMapProvider>(context, listen: false);

    const duration = Duration(seconds: 1);
    _timer = Timer.periodic(duration, (Timer t) async {
      DistanceResult result = await calculateTraveledDistance(_lastPosition);

      if (result.distance > 25) {
        _lastPosition = result.position;
        courierMapProvider.updateMarker(result.position);
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
      });
    } catch (e) {
      debugPrint('Error sending location update: $e');
    }
  }

  Future listenToDeliveryUpdates() async {
    String? courierId = await UserSession.getUserId();
    AudioPlayer player = AudioPlayer();

    _socketService.on("$courierId", (data) async {
      await player.play(AssetSource('sounds/notification_sound.wav'));
      _serviceFound = true;
      notifyListeners();
    });
  }

  Future initCurrentLocation() async {
    try {
      String? courierId = await UserSession.getUserId();

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      _socketService.emit('updateLocation', {
        'courierId': courierId,
        'latitude': position.latitude,
        'longitude': position.longitude,
      });
    } catch (e) {
      debugPrint('Error sending location update: $e');
    }
  }
}

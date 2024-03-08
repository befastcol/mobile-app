import 'package:be_fast/api/users.dart';
import 'package:be_fast/models/user.dart';
import 'package:be_fast/shared/utils/icon_helper.dart';
import 'package:be_fast/shared/utils/user_session.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CourierMapProvider with ChangeNotifier {
  GoogleMapController? _googleMapController;
  bool _isInitialized = false;
  CameraPosition? _initialCameraPosition;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  BitmapDescriptor? icon;

  GoogleMapController? get googleMapController => _googleMapController;
  CameraPosition? get initialCameraPosition => _initialCameraPosition;
  Set<Marker> get markers => _markers;
  Set<Polyline> get polylines => _polylines;
  bool get isInitialized => _isInitialized;

  CourierMapProvider() {
    initMap();
  }

  @override
  void dispose() {
    googleMapController?.dispose();
    markers.clear();
    polylines.clear();
    super.dispose();
  }

  Future initMap() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    _initialCameraPosition = CameraPosition(
      tilt: 100,
      target: LatLng(position.latitude, position.longitude),
      zoom: 19,
    );
    setInitialized(true);
    await _initIcon();
    updateMarker(position);
    animateCamera(position);
  }

  Future _initIcon() async {
    try {
      String? courierId = await UserSession.getUserId();
      UserModel courier = await UsersAPI.getUser(userId: courierId);
      icon = await getVehicleIcon(courier.vehicle, size: 125);
    } catch (e) {
      debugPrint("$e");
    }
  }

  void setInitialized(bool value) {
    _isInitialized = value;
    notifyListeners();
  }

  void updateMarker(Position position) {
    _markers.removeWhere(
        (marker) => marker.markerId == const MarkerId('currentLocation'));

    if (icon != null) {
      _markers.add(Marker(
          markerId: const MarkerId('currentLocation'),
          position: LatLng(position.latitude, position.longitude),
          icon: icon!));
    }

    notifyListeners();
  }

  void animateCamera(Position position) {
    CameraPosition cameraPosition = CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 19,
      bearing: position.heading,
      tilt: 100,
    );
    _googleMapController
        ?.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    notifyListeners();
  }

  void setGoogleMapController(controller) {
    _googleMapController = controller;
    notifyListeners();
  }

  void updateMarkers(Marker marker) {
    _markers.add(marker);
    notifyListeners();
  }

  void addPolylines(Polyline polyline) {
    _polylines.add(polyline);
    notifyListeners();
  }
}
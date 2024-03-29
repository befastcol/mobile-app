import 'package:be_fast/api/users.dart';
import 'package:be_fast/models/user.dart';
import 'package:be_fast/shared/utils/default_position.dart';
import 'package:be_fast/shared/utils/icon_helper.dart';
import 'package:be_fast/shared/utils/location_helper.dart';
import 'package:be_fast/shared/utils/user_session.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CourierMapProvider with ChangeNotifier {
  GoogleMapController? _googleMapController;
  CameraPosition? _initialCameraPosition;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  BitmapDescriptor? _icon;

  GoogleMapController? get googleMapController => _googleMapController;
  CameraPosition? get initialCameraPosition => _initialCameraPosition;
  Set<Marker> get markers => _markers;
  Set<Polyline> get polylines => _polylines;

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
    try {
      Position position = await LocationHelper.determinePosition();
      _initialCameraPosition = CameraPosition(
        tilt: 90,
        target: LatLng(position.latitude, position.longitude),
        zoom: 19,
      );
      await _initIcon();
      updateMarker(position);
      animateCamera(position);
    } catch (e) {
      _initialCameraPosition = CameraPosition(target: defaultLatLng, zoom: 14);
      notifyListeners();
    }
  }

  Future _initIcon() async {
    try {
      String? courierId = await UserSession.getUserId();
      UserModel courier = await UsersAPI.getUser(userId: courierId);
      _icon = await getVehicleIcon(courier.vehicle, size: 125);
    } catch (e) {
      debugPrint("$e");
    } finally {
      notifyListeners();
    }
  }

  void updateMarker(Position position) {
    if (_icon != null) {
      _markers.removeWhere(
          (marker) => marker.markerId == const MarkerId('currentLocation'));

      _markers.add(Marker(
          markerId: const MarkerId('currentLocation'),
          position: LatLng(position.latitude, position.longitude),
          icon: _icon!));
      notifyListeners();
    }
  }

  void animateCamera(Position position) {
    CameraPosition cameraPosition = CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 19,
      bearing: position.heading,
      tilt: 90,
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

  void resetState() {
    _markers.removeWhere((marker) =>
        marker.markerId == const MarkerId('origin') ||
        marker.markerId == const MarkerId('destination'));

    polylines.clear();
    notifyListeners();
  }
}

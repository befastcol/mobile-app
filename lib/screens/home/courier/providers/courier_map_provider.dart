import 'package:be_fast/api/users.dart';
import 'package:be_fast/models/user.dart';
import 'package:be_fast/utils/icon_helper.dart';
import 'package:be_fast/utils/user_session.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CourierMapProvider with ChangeNotifier {
  GoogleMapController? _googleMapController;
  CameraPosition? _initialCameraPosition;
  Set<Marker>? _markers;
  BitmapDescriptor? icon;

  GoogleMapController? get googleMapController => _googleMapController;
  CameraPosition? get initialCameraPosition => _initialCameraPosition;
  Set<Marker>? get markers => _markers;

  @override
  void dispose() {
    _googleMapController?.dispose();
    super.dispose();
  }

  Future initMap() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    _initialCameraPosition = CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 19,
    );
    await _initIcon();
    updateMarker(position);
    _animateCamera(position);
  }

  Future _initIcon() async {
    String? courierId = await UserSession.getUserId();
    UserModel courier = await UsersAPI.getUser(userId: courierId);
    icon = await getVehicleIcon(courier.vehicle);
  }

  void updateMarker(Position position) {
    if (icon != null) {
      _markers = {
        Marker(
            markerId: const MarkerId('currentLocation'),
            position: LatLng(position.latitude, position.longitude),
            icon: icon!),
      };
    }

    notifyListeners();
  }

  void _animateCamera(Position position) {
    _googleMapController?.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(position.latitude, position.longitude),
      ),
    );
    notifyListeners();
  }

  void setGoogleMapController(controller) {
    _googleMapController = controller;
    notifyListeners();
  }
}

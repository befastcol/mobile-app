import 'dart:async';
import 'dart:math';
import 'package:be_fast/api/deliveries.dart';
import 'package:be_fast/api/google_maps.dart';
import 'package:be_fast/api/users.dart';
import 'package:be_fast/models/delivery.dart';
import 'package:be_fast/models/location.dart';
import 'package:be_fast/utils/location_helper.dart';
import 'package:flutter/material.dart';
import 'package:be_fast/models/user.dart';
import 'package:be_fast/utils/user_session.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserProvider extends ChangeNotifier {
  UserModel _user = UserModel(
      id: '',
      name: '',
      phone: '',
      role: '',
      originLocation: LocationModel(title: '', subtitle: '', coordinates: []));

  LocationModel _origin =
      LocationModel(coordinates: [], title: '', subtitle: '');
  LocationModel _destination =
      LocationModel(coordinates: [], title: '', subtitle: '');
  int _price = 0;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final Completer<GoogleMapController> _controller = Completer();
  CameraPosition? _initialCameraPosition;

  bool _isUpdatingLocation = false;
  bool _isSearchingDeliveries = false;

  late DeliveryModel _delivery;

  UserModel get user => _user;
  LocationModel get origin => _origin;
  LocationModel get destination => _destination;
  int get price => _price;

  Set<Marker>? get markers => _markers;
  Set<Polyline> get polylines => _polylines;
  Completer<GoogleMapController> get controller => _controller;
  CameraPosition? get initialCameraPosition => _initialCameraPosition;

  bool get isUpdatingLocation => _isUpdatingLocation;
  bool get isSearchingDeliveries => _isSearchingDeliveries;
  DeliveryModel get delivery => _delivery;

  Future<void> initializeMap() async {
    try {
      Position position = await LocationHelper.determinePosition();
      updateCameraPosition(position);
    } catch (e) {
      debugPrint('initializeMap: $e');
    }
  }

  Future initializeUser() async {
    try {
      String? userId = await UserSession.getUserId();
      _user = await UsersAPI().getUserById(userId: userId);
      updateOrigin(
          LatLng(_user.originLocation.coordinates[1],
              _user.originLocation.coordinates[0]),
          _user.originLocation.title,
          _user.originLocation.subtitle);
      notifyListeners();
    } catch (e) {
      debugPrint("initializeUser: $e");
    }
  }

  void updateUserName(String newName) {
    _user = UserModel(
        id: _user.id,
        name: newName,
        phone: _user.phone,
        role: _user.role,
        originLocation: _user.originLocation);
    notifyListeners();
  }

  void updateCameraPosition(Position position) {
    LatLng currentLatLng = LatLng(position.latitude, position.longitude);
    _initialCameraPosition = CameraPosition(target: currentLatLng, zoom: 17);
    notifyListeners();
  }

  Future<void> moveCamera(LatLng target) async {
    GoogleMapController mapController = await _controller.future;
    mapController.animateCamera(CameraUpdate.newLatLngZoom(target, 17));
    notifyListeners();
  }

  Future<void> getAddressLocation() async {
    Position position = await LocationHelper.determinePosition();
    Placemark placemark = await LocationHelper.getPlacemarks(position);

    updateOrigin(
        LatLng(position.latitude, position.longitude),
        "${placemark.name}",
        "${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}");
  }

  void updateOrigin(LatLng latlng, String title, String subtitle) {
    _origin = LocationModel(
        coordinates: [latlng.longitude, latlng.latitude],
        title: title,
        subtitle: subtitle);
    notifyListeners();

    _markers.removeWhere((m) => m.markerId == const MarkerId('origin'));

    _markers.add(Marker(
      markerId: const MarkerId('origin'),
      position: latlng,
      icon: BitmapDescriptor.defaultMarkerWithHue(200),
    ));
    _checkRouteAndAdjustCamera();
  }

  Future createDelivery() async {
    try {
      _isSearchingDeliveries = true;
      notifyListeners();
      _delivery = await DeliveriesAPI().createDelivery(
          origin: _origin, destination: _destination, price: _price);
    } finally {
      _isSearchingDeliveries = true;
      notifyListeners();
    }
  }

  void updateDestination(LatLng latlng, String title, String subtitle) {
    _destination = LocationModel(
        coordinates: [latlng.longitude, latlng.latitude],
        title: title,
        subtitle: subtitle);

    _markers.removeWhere((m) => m.markerId == const MarkerId('destination'));

    _markers.add(Marker(
      markerId: const MarkerId('destination'),
      position: latlng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    ));
    _checkRouteAndAdjustCamera();
  }

  void _checkRouteAndAdjustCamera() async {
    if (_origin.coordinates.isNotEmpty && _destination.coordinates.isNotEmpty) {
      try {
        RouteDetails routeDetails =
            await GoogleMapsAPI().getRouteCoordinates(_origin, _destination);
        _price = await DeliveriesAPI().getDeliveryPrice(
            distance: routeDetails.distance, duration: routeDetails.duration);

        _polylines.clear();

        _polylines.add(Polyline(
          polylineId: const PolylineId('route'),
          points: routeDetails.polylinePoints,
          color: Colors.blueAccent,
          width: 5,
        ));
        _fitRoute();
      } catch (e) {
        debugPrint("_checkRouteAndAdjustCamera: $e");
      }
    }
  }

  Future<void> _fitRoute() async {
    GoogleMapController mapController = await _controller.future;

    LatLng southwest = LatLng(
      min(_origin.coordinates[1], _destination.coordinates[1]),
      min(_origin.coordinates[0], _destination.coordinates[0]),
    );
    LatLng northeast = LatLng(
      max(_origin.coordinates[1], _destination.coordinates[1]),
      max(_origin.coordinates[0], _destination.coordinates[0]),
    );

    LatLngBounds bounds =
        LatLngBounds(southwest: southwest, northeast: northeast);

    await mapController
        .animateCamera(CameraUpdate.newLatLngBounds(bounds, 120.0));
    setIsUpdatingLocation(false);
  }

  void setIsUpdatingLocation(bool isUpdating) {
    _isUpdatingLocation = isUpdating;
    notifyListeners();
  }

  void setIsSearchingDeliveries(bool isSearching) {
    _isSearchingDeliveries = isSearching;
    notifyListeners();
  }
}

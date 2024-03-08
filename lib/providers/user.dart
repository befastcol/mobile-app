import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:be_fast/api/deliveries.dart';
import 'package:be_fast/api/google_maps.dart';
import 'package:be_fast/api/users.dart';
import 'package:be_fast/models/custom/custom.dart';
import 'package:be_fast/models/delivery.dart';
import 'package:be_fast/shared/utils/icons_helper.dart';
import 'package:be_fast/shared/utils/location_helper.dart';
import 'package:be_fast/models/user.dart';
import 'package:be_fast/shared/utils/user_session.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OldUserProvider extends ChangeNotifier {
  UserModel _user = UserModel(
    id: '',
    phone: '',
    documents: Documents(driverLicense: Document(), ine: Document()),
    currentLocation: Point(),
    isDisabled: false,
    originLocation: Point(),
  );

  Point _origin = Point();
  Point _destination = Point();
  int _price = 0;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final Completer<GoogleMapController> _controller = Completer();
  CameraPosition? _initialCameraPosition;

  bool _isUpdatingLocation = false;
  bool _isSearchingDeliveries = false;

  late DeliveryModel _delivery;

  UserModel get user => _user;
  Point get origin => _origin;
  Point get destination => _destination;
  int get price => _price;
  DeliveryModel get delivery => _delivery;

  Set<Marker>? get markers => _markers;
  Set<Polyline> get polylines => _polylines;
  Completer<GoogleMapController> get controller => _controller;
  CameraPosition? get initialCameraPosition => _initialCameraPosition;

  bool get isUpdatingLocation => _isUpdatingLocation;
  bool get isSearchingDeliveries => _isSearchingDeliveries;

  OldUserProvider() {
    initializeUser();
    initializeMap();
    initializeCouriers();
  }

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
      debugPrint(userId);

      _user = await UsersAPI.getUser(userId: userId);
      FlutterNativeSplash.remove();
      notifyListeners();
      updateOrigin(
          LatLng(_user.originLocation.coordinates[1],
              _user.originLocation.coordinates[0]),
          _user.originLocation.title,
          _user.originLocation.subtitle,
          _user.originLocation.city);
    } catch (e) {
      debugPrint("initializeUser: $e");
    }
  }

  Future initializeCouriers() async {
    try {
      List<UserModel> couriers = await UsersAPI.getAvailableCouriers();
      final motoIcon =
          await getBytesFromAsset('assets/images/moto_icon.png', 100);
      final carIcon =
          await getBytesFromAsset('assets/images/car_icon.png', 100);

      for (var courier in couriers) {
        LatLng position = LatLng(courier.currentLocation?.coordinates[1] ?? 0,
            courier.currentLocation?.coordinates[0] ?? 0);

        if (courier.vehicle == "motorcycle") {
          _markers.add(Marker(
            markerId: MarkerId(courier.id),
            position: position,
            icon: motoIcon,
          ));
        }
        if (courier.vehicle == "car") {
          _markers.add(Marker(
            markerId: MarkerId(courier.id),
            position: position,
            icon: carIcon,
          ));
        }
        notifyListeners();
      }
      notifyListeners();
    } catch (e) {
      debugPrint("initializeCouriers: $e");
    }
  }

  void updateUserName(String newName) {
    _user = _user.copyWith(name: newName);
    notifyListeners();
  }

  void updateUserVehicle(String vehicle) {
    _user = _user.copyWith(vehicle: vehicle);
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

  void updateOrigin(LatLng latlng, String title, String subtitle, String city) {
    _origin = Point(
        coordinates: [latlng.longitude, latlng.latitude],
        city: city,
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
      _delivery = await DeliveriesAPI.createDelivery(
          origin: _origin, destination: _destination, price: _price);
    } catch (e) {
      debugPrint("createDelivery: $e");
    }
  }

  Future<void> cancelDelivery({
    required Function onSuccess,
    required Function onError,
  }) async {
    try {
      await DeliveriesAPI.cancelDelivery(deliveryId: _delivery.id);
      onSuccess();
    } catch (e) {
      onError();
      debugPrint("cancelDelivery: $e");
    }
  }

  void updateDestination(
      LatLng latlng, String title, String subtitle, String city) {
    _destination = Point(
        coordinates: [latlng.longitude, latlng.latitude],
        city: city,
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
        _price = await DeliveriesAPI.getDeliveryPrice(
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

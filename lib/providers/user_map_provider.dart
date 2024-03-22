import 'dart:async';
import 'dart:math';
import 'package:be_fast/api/google_maps.dart';
import 'package:be_fast/providers/delivery_provider.dart';
import 'package:be_fast/shared/utils/default_position.dart';
import 'package:be_fast/shared/utils/user_session.dart';
import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../api/users.dart';
import '../models/user.dart';
import '../shared/utils/icons_helper.dart';
import '../shared/utils/location_helper.dart';

class UserMapProvider extends ChangeNotifier {
  final DeliveryProvider _deliveryProvider;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final Completer<GoogleMapController> _controller = Completer();
  CameraPosition? _initialCameraPosition;

  Set<Marker> get markers => _markers;
  Set<Polyline> get polylines => _polylines;
  Completer<GoogleMapController> get controller => _controller;
  CameraPosition? get initialCameraPosition => _initialCameraPosition;

  UserMapProvider(this._deliveryProvider) {
    _initUserPosition();
    _initOriginPosition();
    _initiAvailableCouriersMarkers();
  }

  Future _initUserPosition() async {
    try {
      Position position = await LocationHelper.determinePosition();
      updateCameraPosition(position);
    } catch (e) {
      debugPrint("$e");

      _initialCameraPosition =
          CameraPosition(target: defaultPosition, zoom: 14);
      notifyListeners();
    }
  }

  Future _initOriginPosition() async {
    String? userId = await UserSession.getUserId();
    UserModel user = await UsersAPI.getUser(userId: userId);

    if (user.originLocation.coordinates.length == 2) {
      addMarker(
          'origin',
          LatLng(user.originLocation.coordinates[1],
              user.originLocation.coordinates[0]),
          BitmapDescriptor.defaultMarkerWithHue(200));
    }
  }

  Future _initiAvailableCouriersMarkers() async {
    List<UserModel> couriers = await UsersAPI.getAvailableCouriers();
    Map<String, BitmapDescriptor> icons = await loadVehicleIcons();

    for (var courier in couriers) {
      if (courier.currentLocation?.coordinates != null &&
          courier.currentLocation!.coordinates.length == 2) {
        LatLng position = LatLng(
          courier.currentLocation?.coordinates[1] ?? 0,
          courier.currentLocation?.coordinates[0] ?? 0,
        );
        BitmapDescriptor icon = getIconForVehicle(courier.vehicle, icons);
        _markers.add(Marker(
          markerId: MarkerId(courier.id),
          position: position,
          icon: icon,
        ));
      }
    }
    notifyListeners();
  }

  void updateCameraPosition(Position position) {
    LatLng currentLatLng = LatLng(position.latitude, position.longitude);
    _initialCameraPosition = CameraPosition(target: currentLatLng, zoom: 17);
    notifyListeners();
  }

  void addMarker(String markerId, LatLng position, BitmapDescriptor icon) {
    _markers.removeWhere((marker) => marker.markerId == MarkerId(markerId));
    _markers.add(
        Marker(markerId: MarkerId(markerId), position: position, icon: icon));
    _checkRouteAndAdjustCamera();
    notifyListeners();
  }

  void _checkRouteAndAdjustCamera() async {
    if (_deliveryProvider.origin.coordinates.isNotEmpty &&
        _deliveryProvider.destination.coordinates.isNotEmpty) {
      try {
        RouteDetails routeDetails = await GoogleMapsAPI().getRouteCoordinates(
            _deliveryProvider.origin, _deliveryProvider.destination);
        _deliveryProvider.getDeliveryPrice(
            routeDetails.distance, routeDetails.duration);

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
      min(_deliveryProvider.origin.coordinates[1],
          _deliveryProvider.destination.coordinates[1]),
      min(_deliveryProvider.origin.coordinates[0],
          _deliveryProvider.destination.coordinates[0]),
    );
    LatLng northeast = LatLng(
      max(_deliveryProvider.origin.coordinates[1],
          _deliveryProvider.destination.coordinates[1]),
      max(_deliveryProvider.origin.coordinates[0],
          _deliveryProvider.destination.coordinates[0]),
    );

    LatLngBounds bounds =
        LatLngBounds(southwest: southwest, northeast: northeast);

    await mapController
        .animateCamera(CameraUpdate.newLatLngBounds(bounds, 120.0));

    notifyListeners();
  }

  void resetValues() {
    polylines.clear();
    _markers.removeWhere(
        (marker) => marker.markerId == const MarkerId('destination'));
    _initiAvailableCouriersMarkers();
    notifyListeners();
  }
}

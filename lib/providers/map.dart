import 'dart:async';
import 'dart:math';
import 'package:be_fast/api/deliveries.dart';
import 'package:be_fast/utils/location_helper.dart';
import 'package:flutter/material.dart';
import 'package:be_fast/models/location.dart';
import 'package:be_fast/models/delivery.dart';
import 'package:be_fast/api/google_maps.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapProvider extends ChangeNotifier {
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
  late Delivery _delivery;

  LocationModel get origin => _origin;
  LocationModel get destination => _destination;
  int get price => _price;

  Set<Marker>? get markers => _markers;
  Set<Polyline> get polylines => _polylines;
  Completer<GoogleMapController> get controller => _controller;
  CameraPosition? get initialCameraPosition => _initialCameraPosition;

  bool get isUpdatingLocation => _isUpdatingLocation;
  bool get isSearchingDeliveries => _isSearchingDeliveries;
  Delivery get delivery => _delivery;

  Future<void> initializeMap() async {
    try {
      Position position = await LocationHelper.determinePosition();
      updateCameraPosition(position);
    } catch (e) {
      debugPrint('initializeMap: $e');
    }
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
        coordinates: [latlng.latitude, latlng.longitude],
        title: title,
        subtitle: subtitle);

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
        coordinates: [latlng.latitude, latlng.longitude],
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
      LatLng originLatLng =
          LatLng(_origin.coordinates[0], _origin.coordinates[1]);
      LatLng destinationLatLng =
          LatLng(_destination.coordinates[0], _destination.coordinates[1]);

      GoogleMapsAPI mapsApi = GoogleMapsAPI();

      try {
        RouteDetails routeDetails =
            await mapsApi.getRouteCoordinates(originLatLng, destinationLatLng);

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
      min(_origin.coordinates[0], _destination.coordinates[0]),
      min(_origin.coordinates[1], _destination.coordinates[1]),
    );
    LatLng northeast = LatLng(
      max(_origin.coordinates[0], _destination.coordinates[0]),
      max(_origin.coordinates[1], _destination.coordinates[1]),
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

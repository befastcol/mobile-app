import 'dart:async';
import 'dart:math';
import 'package:be_fast/api/google_maps.dart';
import 'package:be_fast/models/location.dart';
import 'package:be_fast/screens/home/home/helpers/location_helper.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapProvider extends ChangeNotifier {
  Location _origin = Location(coordinates: [], title: '', subtitle: '');
  Location _destination = Location(coordinates: [], title: '', subtitle: '');
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final Completer<GoogleMapController> _controller = Completer();
  CameraPosition? _initialCameraPosition;

  Location get origin => _origin;
  Location get destination => _destination;
  Set<Marker>? get markers => _markers;
  Set<Polyline> get polylines => _polylines;
  Completer<GoogleMapController> get controller => _controller;
  CameraPosition? get initialCameraPosition => _initialCameraPosition;

  Future<void> initializeMap() async {
    try {
      Position position = await LocationHelper.determinePosition();
      updateCameraPosition(position);
    } catch (e) {
      debugPrint('Error al obtener ubicación: $e');
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
    String titlePlace = await LocationHelper.getAddressFromLatLng(
        position.latitude, position.longitude);
    String subtitlePlace = await LocationHelper.getLongPlace(position);
    updateOrigin(LatLng(position.latitude, position.longitude), titlePlace,
        subtitlePlace);
  }

  void updateOrigin(LatLng latlng, String title, String subtitle) {
    // Actualizar la ubicación de origen
    _origin = Location(
        coordinates: [latlng.latitude, latlng.longitude],
        title: title,
        subtitle: subtitle);

    // Remover el marcador existente de origen si existe
    _markers.removeWhere((m) => m.markerId == const MarkerId('origin'));

    // Añadir el nuevo marcador de origen
    _markers.add(Marker(
      markerId: const MarkerId('origin'),
      position: latlng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    ));

    _checkRouteAndAdjustCamera();
  }

  void updateDestination(LatLng latlng, String title, String subtitle) {
    _destination = Location(
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

      // Instancia de DirectionsAPI
      GoogleMapsApi mapsApi = GoogleMapsApi();

      try {
        // Obtener las coordenadas de la ruta
        List<LatLng> routeCoords =
            await mapsApi.getRouteCoordinates(originLatLng, destinationLatLng);

        // Limpiar polylines existentes
        _polylines.clear();

        // Añadir la nueva polyline con la ruta detallada
        _polylines.add(Polyline(
          polylineId: const PolylineId('route'),
          points: routeCoords,
          color: Colors.blueAccent,
          width: 5,
        ));

        _fitRoute();
      } catch (e) {
        debugPrint("Error al obtener la ruta: $e");
      }
    }
  }

  Future<void> _fitRoute() async {
    GoogleMapController mapController = await _controller.future;
    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        min(_origin.coordinates[0], _destination.coordinates[0]),
        min(_origin.coordinates[1], _destination.coordinates[1]),
      ),
      northeast: LatLng(
        max(_origin.coordinates[0], _destination.coordinates[0]),
        max(_origin.coordinates[1], _destination.coordinates[1]),
      ),
    );

    await mapController
        .animateCamera(CameraUpdate.newLatLngBounds(bounds, 50.0));
    notifyListeners();
  }
}

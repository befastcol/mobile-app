import 'dart:convert';
import 'package:be_fast/models/custom/custom.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteDetails {
  final List<LatLng> polylinePoints;
  final int distance;
  final int duration;

  RouteDetails(
      {required this.polylinePoints,
      required this.distance,
      required this.duration});
}

class GoogleMapsAPI {
  static const String _googleMapsBaseUrl =
      'https://maps.googleapis.com/maps/api';
  String? apiKey = dotenv.env['GOOGLE_API_KEY'];

  Future<RouteDetails> getRouteCoordinates(
      Point origin, Point destination) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_googleMapsBaseUrl'
          '/directions/json?'
          'origin=${origin.coordinates[1]},${origin.coordinates[0]}&'
          'destination=${destination.coordinates[1]},${destination.coordinates[0]}&'
          'key=$apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final encodedPoly = route['overview_polyline']['points'];
          final List<LatLng> polylinePoints = _decodePolyline(encodedPoly);

          final int distance = route['legs'][0]['distance']['value'];
          final int duration = route['legs'][0]['duration']['value'];

          return RouteDetails(
            polylinePoints: polylinePoints,
            distance: distance,
            duration: duration,
          );
        }
      }
      throw Exception('Failed to fetch directions');
    } catch (e) {
      throw Exception(e);
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      LatLng p = LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
      points.add(p);
    }
    return points;
  }

  Future<List<dynamic>> getAutocompleteResults(
      String query, Position position) async {
    final String url =
        '$_googleMapsBaseUrl/place/autocomplete/json?input=$query&location=${position.latitude},${position.longitude}&radius=25000&strictbounds=true&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['predictions'] as List;
    } else {
      throw Exception('Failed to fetch autocomplete results');
    }
  }

  Future<Map<String, dynamic>> getPlaceLatLng(String placeId) async {
    final String url =
        '$_googleMapsBaseUrl/place/details/json?place_id=$placeId&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final locationData = data['result']['geometry']['location'];

        // Cambio aquí: Asegurarse de que 'address_components' es una lista
        final List<dynamic> addressComponents =
            data['result']['address_components'];
        final city = addressComponents.firstWhere(
          (component) {
            // Asegurándose de que 'component' es un Map y 'types' es una lista
            final List<dynamic> types = component['types'];
            return types.contains('locality');
          },
          orElse: () => {
            'long_name': 'Unknown'
          }, // Proporcionar un valor predeterminado como Map
        )['long_name'];

        return {
          'latLng': LatLng(locationData['lat'], locationData['lng']),
          'city': city,
        };
      } else {
        throw Exception(
            'Failed to fetch place details with status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch place details: $e');
    }
  }
}

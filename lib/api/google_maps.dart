// directions_api.dart

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapsApi {
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json?';
  String? apiKey = dotenv.env['GOOGLE_API_KEY'];

  GoogleMapsApi();

  Future<List<LatLng>> getRouteCoordinates(
      LatLng origin, LatLng destination) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl'
        'origin=${origin.latitude},${origin.longitude}&'
        'destination=${destination.latitude},${destination.longitude}&'
        'key=$apiKey',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['routes'] != null && data['routes'].isNotEmpty) {
        final route = data['routes'][0];
        final encodedPoly = route['overview_polyline']['points'];
        final List<LatLng> polylinePoints = _decodePolyline(encodedPoly);
        return polylinePoints;
      }
    }
    throw Exception('Failed to fetch directions');
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
}

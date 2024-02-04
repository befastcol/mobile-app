import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class LocationHelper {
  static Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  static Future<String> getLongPlace(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      Placemark place = placemarks[0];
      return '${place.name}, ${place.locality}, ${place.postalCode}';
    } catch (e) {
      throw Exception('Failed to get place name: $e');
    }
  }

  static Future<List<dynamic>> getAutocompleteResults(
      String query, Position? position) async {
    try {
      String url = _getGoogleMapsUrl(query, position);
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['predictions'] as List;
      } else {
        throw Exception('Error al obtener lugares de Google Places');
      }
    } catch (e) {
      return [];
    }
  }

  static Future<LatLng> getPlaceLatLng(String placeId) async {
    String? apiKey = dotenv.env['GOOGLE_API_KEY'];
    final String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final locationData = data['result']['geometry']['location'];
        double lat = locationData['lat'];
        double lng = locationData['lng'];
        return LatLng(lat, lng);
      } else {
        throw Exception('Error al obtener detalles del lugar');
      }
    } catch (e) {
      throw Exception('Error al obtener detalles del lugar: $e');
    }
  }

  static Future<String> getAddressFromLatLng(
      double latitude, double longitude) async {
    String? apiKey = dotenv.env['GOOGLE_API_KEY'];
    final String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['results'] != null &&
            responseData['results'].length > 0) {
          var addressComponents =
              responseData['results'][0]['address_components'];

          String streetNumber = '';
          String route = '';

          for (var component in addressComponents) {
            if (component['types'].contains('street_number')) {
              streetNumber = component['long_name'];
            }
            if (component['types'].contains('route')) {
              route = component['long_name'];
            }
          }

          return '$route $streetNumber';
        } else {
          throw Exception('No se encontraron resultados.');
        }
      } else {
        throw Exception('Error al contactar con el servidor de Google Maps.');
      }
    } catch (e) {
      throw Exception('Error al obtener la dirección: $e');
    }
  }

  static String _getGoogleMapsUrl(String query, Position? position) {
    String? apiKey = dotenv.env['GOOGLE_API_KEY'];

    final String location =
        '&location=${position?.latitude},${position?.longitude}';
    const String radius = '&radius=25000';
    final String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query$location$radius&strictbounds=true&key=$apiKey';
    return url;
  }
}

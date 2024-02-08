import 'package:be_fast/constants/api.dart';
import 'package:be_fast/models/delivery.dart';
import 'package:be_fast/models/location.dart';
import 'package:be_fast/utils/user_session.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<Delivery>> getUserDeliveries(String? userId) async {
  final url = Uri.parse('$baseUrl/deliveries/$userId');

  try {
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception(json.decode(response.body)['message']);
    }

    List<dynamic> deliveryList = json.decode(response.body);
    return deliveryList.map((json) => Delivery.fromJson(json)).toList();
  } catch (error) {
    throw Exception('Error al obtener las entregas: $error');
  }
}

Future<Delivery> createDelivery({
  required LocationModel origin,
  required LocationModel destination,
}) async {
  String? userId = await UserSession.getUserId();
  final url = Uri.parse('$baseUrl/deliveries/create/$userId');

  Map<String, dynamic> body = {
    "origin": {
      "coordinates": origin.coordinates,
      "title": origin.title,
      "subtitle": origin.subtitle,
    },
    "destination": {
      "coordinates": destination.coordinates,
      "title": destination.title,
      "subtitle": destination.subtitle,
    },
    "price": 50,
  };

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode(body),
    );

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      return Delivery.fromJson(responseData);
    } else {
      throw Exception(
          'Error al crear la entrega: ${json.decode(response.body)['message']}');
    }
  } catch (error) {
    throw Exception('Error al crear la entrega: $error');
  }
}

import 'package:be_fast/constants/api.dart';
import 'package:be_fast/models/delivery.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<Delivery>> getUserDeliveries(String? userId) async {
  final url = Uri.parse('$baseUrl/delivery/$userId');

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

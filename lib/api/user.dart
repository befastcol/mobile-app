import 'package:be_fast/api/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> createUser(String name, String phone) async {
  final url = Uri.parse('$baseUrl/user/create');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': name, 'phone': phone}),
    );

    if (response.statusCode != 201) {
      throw Exception(json.decode(response.body)['message']);
    }

    final data = json.decode(response.body);
    return data['_id'];
  } catch (error) {
    throw Exception('Error en la solicitud: $error');
  }
}

Future<void> updateUser({String? userId, String? name}) async {
  final url = Uri.parse('$baseUrl/user/update/$userId');

  try {
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': name}),
    );

    if (response.statusCode != 200) {
      throw Exception(json.decode(response.body)['message']);
    }
  } catch (error) {
    throw Exception('Error al actualizar el usuario: $error');
  }
}

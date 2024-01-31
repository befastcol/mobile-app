import 'package:be_fast/constants/api.dart';
import 'package:be_fast/models/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> createUser(String name, String phone) async {
  final url = Uri.parse('$baseUrl/users/create');

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
  final url = Uri.parse('$baseUrl/users/update/$userId');

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

Future<List<UserModel>> getAllUsers() async {
  final url = Uri.parse('$baseUrl/users/all');

  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => UserModel.fromJson(json)).toList();
    } else {
      throw Exception(json.decode(response.body)['message']);
    }
  } catch (error) {
    throw Exception('Error al obtener todos los usuarios: $error');
  }
}

Future<List<UserModel>> getAcceptedCouriers() async {
  final url = Uri.parse('$baseUrl/couriers/accepted');

  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => UserModel.fromJson(json)).toList();
    } else {
      throw Exception(json.decode(response.body)['message']);
    }
  } catch (error) {
    throw Exception('Error al obtener couriers aceptados: $error');
  }
}

Future<List<UserModel>> getPendingCouriers() async {
  final url = Uri.parse('$baseUrl/couriers/pending');

  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(json.decode(response.body)['message']);
    }
  } catch (error) {
    throw Exception('Error al obtener couriers pendientes: $error');
  }
}

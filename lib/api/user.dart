import 'package:be_fast/constants/api.dart';
import 'package:be_fast/models/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateUserResponse {
  final String userId;
  final bool alreadyExists;

  CreateUserResponse({required this.userId, required this.alreadyExists});
}

Future<CreateUserResponse> createUser({String? name, String? phone}) async {
  final url = Uri.parse('$baseUrl/users/create');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': name, 'phone': phone}),
    );

    final data = json.decode(response.body);

    if (data['_id'] == null) {
      throw Exception('El campo "_id" no está presente en la respuesta');
    }

    return CreateUserResponse(
      userId: data['_id'],
      alreadyExists: response.statusCode == 409,
    );
  } catch (error) {
    throw Exception('Error en la solicitud: $error');
  }
}

Future<UserModel> getUserById(String? userId) async {
  try {
    final url = Uri.parse('$baseUrl/users/$userId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      Map<String, dynamic> user = json.decode(response.body);
      return UserModel.fromJson(user);
    }
    throw Exception(json.decode(response.body)['message']);
  } catch (e) {
    throw Exception(e);
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
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => UserModel.fromJson(json)).toList();
    } else {
      throw Exception(json.decode(response.body)['message']);
    }
  } catch (error) {
    throw Exception('Error al obtener couriers pendientes: $error');
  }
}

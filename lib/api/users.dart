import 'dart:convert';
import 'package:be_fast/models/location.dart';
import 'package:http/http.dart';

import 'package:be_fast/models/user.dart';
import 'package:be_fast/api/constants/base_url.dart';

class UsersAPI {
  Future<CreateUserResponse> createUser({required String phone}) async {
    try {
      Response response = await post(
        Uri.parse('$baseUrl/users/create'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'phone': phone}),
      );

      return CreateUserResponse(
        userId: json.decode(response.body)['_id'],
        alreadyExists: response.statusCode == 409,
      );
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<UserModel> getUserById({required String? userId}) async {
    try {
      Response response = await get(Uri.parse('$baseUrl/users/$userId'));
      if (response.statusCode == 200) {
        Map<String, dynamic> user = json.decode(response.body);
        return UserModel.fromJson(user);
      }
      throw Exception(json.decode(response.body)['message']);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> updateUserName(
      {required String? userId, required String name}) async {
    try {
      Response response = await put(
        Uri.parse('$baseUrl/users/update/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name}),
      );

      if (response.statusCode != 200) {
        throw Exception(json.decode(response.body)['message']);
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> saveUserLocation(
      {required String? userId, required LocationModel originLocation}) async {
    try {
      Response response = await put(
        Uri.parse('$baseUrl/users/update/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'originLocation': {
            'type': 'Point',
            'title': originLocation.title,
            'subtitle': originLocation.subtitle,
            'coordinates': originLocation.coordinates
          }
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(json.decode(response.body)['message']);
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      Response response = await get(Uri.parse('$baseUrl/users/all'));
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => UserModel.fromJson(json)).toList();
      }
      throw Exception(json.decode(response.body)['message']);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<UserModel>> getAcceptedCouriers() async {
    try {
      Response response =
          await get(Uri.parse('$baseUrl/users/couriers/accepted'));
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => UserModel.fromJson(json)).toList();
      }
      throw Exception(json.decode(response.body)['message']);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<UserModel>> getPendingCouriers() async {
    try {
      final response = await get(Uri.parse('$baseUrl/users/couriers/pending'));
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => UserModel.fromJson(json)).toList();
      }
      throw Exception(json.decode(response.body)['message']);
    } catch (e) {
      throw Exception(e);
    }
  }
}

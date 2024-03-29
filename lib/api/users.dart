import 'dart:convert';
import 'package:be_fast/models/custom/custom.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';

import 'package:be_fast/models/user.dart';
import 'package:be_fast/api/constants/base_url.dart';

class UsersAPI {
  static Future<CreateUserResponse> createUser({required String phone}) async {
    try {
      Response response = await post(
        Uri.parse('$baseUrlApi/users/create'),
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

  static Future<UserModel> getUser({required String? userId}) async {
    try {
      Response response = await get(Uri.parse('$baseUrlApi/users/$userId'));
      if (response.statusCode == 200) {
        dynamic user = json.decode(response.body);
        return UserModel.fromJson(user);
      }
      throw Exception(json.decode(response.body)['message']);
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<void> updateUserName(
      {required String? userId, required String name}) async {
    try {
      Response response = await put(
        Uri.parse('$baseUrlApi/users/update/$userId'),
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

  static Future<void> updateUserRole(
      {required String? userId, required String role}) async {
    try {
      Response response = await put(
        Uri.parse('$baseUrlApi/users/update/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'role': role}),
      );

      if (response.statusCode != 200) {
        throw Exception(json.decode(response.body)['message']);
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<UserModel> updateCourierStatus(
      {required String? userId, required String status}) async {
    try {
      Response response = await put(
        Uri.parse('$baseUrlApi/users/update/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': status}),
      );
      if (response.statusCode != 200) {
        throw Exception(json.decode(response.body)['message']);
      }

      dynamic user = json.decode(response.body);
      return UserModel.fromJson(user);
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<void> updateUserVehicle(
      {required String? userId, required String vehicle}) async {
    try {
      Response response = await put(
        Uri.parse('$baseUrlApi/users/update/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'vehicle': vehicle}),
      );

      if (response.statusCode != 200) {
        throw Exception(json.decode(response.body)['message']);
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<void> disableUser(
      {required String? userId, required bool isDisabled}) async {
    try {
      Response response = await put(
        Uri.parse('$baseUrlApi/users/update/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'isDisabled': isDisabled}),
      );

      if (response.statusCode != 200) {
        throw Exception(json.decode(response.body)['message']);
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<void> saveUserLocation(
      {required String? userId, required Point originLocation}) async {
    try {
      Response response = await put(
        Uri.parse('$baseUrlApi/users/update/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'originLocation': {
            'type': 'Point',
            'title': originLocation.title,
            'subtitle': originLocation.subtitle,
            'coordinates': originLocation.coordinates,
            'city': originLocation.city
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

  static Future<void> saveUserCurrentLocation(
      {required String? userId, required Position currentLocation}) async {
    try {
      Response response = await put(
        Uri.parse('$baseUrlApi/users/update/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'currentLocation': {
            'type': 'Point',
            'coordinates': [currentLocation.longitude, currentLocation.latitude]
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

  static Future<void> updateCourierCredits(
      {required String? courierId, required int credits}) async {
    try {
      Response response = await put(
        Uri.parse('$baseUrlApi/users/credits/$courierId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'credits': credits}),
      );

      if (response.statusCode != 200) {
        throw Exception(json.decode(response.body)['message']);
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<void> updateUserDocuments(
      {required String? userId,
      required String? ineFront,
      required String? ineBack,
      required String? license}) async {
    try {
      Response response = await put(
        Uri.parse('$baseUrlApi/users/update/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'documents': {
            'INE': {'front': ineFront, 'back': ineBack},
            "driverLicense": {
              'front': license,
            }
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

  static Future<List<UserModel>> getAllUsers() async {
    try {
      Response response = await get(Uri.parse('$baseUrlApi/users/all'));
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => UserModel.fromJson(json)).toList();
      }
      throw Exception(json.decode(response.body)['message']);
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<List<UserModel>> getAcceptedCouriers() async {
    try {
      Response response =
          await get(Uri.parse('$baseUrlApi/users/couriers/accepted'));
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => UserModel.fromJson(json)).toList();
      }
      throw Exception(json.decode(response.body)['message']);
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<List<UserModel>> getPendingCouriers() async {
    try {
      final response =
          await get(Uri.parse('$baseUrlApi/users/couriers/pending'));
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => UserModel.fromJson(json)).toList();
      }
      throw Exception(json.decode(response.body)['message']);
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<List<UserModel>> getAvailableCouriers() async {
    try {
      final response =
          await get(Uri.parse('$baseUrlApi/users/couriers/available'));
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);

        return jsonList.map((json) => UserModel.fromJson(json)).toList();
      }
      throw Exception(json.decode(response.body)['message']);
    } catch (e) {
      return [];
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart';

import 'package:be_fast/models/custom/custom.dart';
import 'package:be_fast/models/delivery.dart';

import 'package:be_fast/shared/utils/user_session.dart';
import 'package:be_fast/api/constants/base_url.dart';

class DeliveriesAPI {
  static Future<List<DeliveryModel>> getUserDeliveries(
      {required String userId}) async {
    try {
      Response response =
          await get(Uri.parse('$baseUrlApi/deliveries/users/$userId'));

      if (response.statusCode == 200) {
        List<dynamic> deliveryListJson = json.decode(response.body);

        return deliveryListJson
            .map((json) => DeliveryModel.fromJson(json))
            .toList();
      }
      throw Exception(json.decode(response.body)['message']);
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<List<DeliveryModel>> getCourierDeliveries(
      {required String? courierId}) async {
    try {
      Response response =
          await get(Uri.parse('$baseUrlApi/deliveries/couriers/$courierId'));
      if (response.statusCode == 200) {
        List<dynamic> deliveryList = json.decode(response.body);
        return deliveryList
            .map((json) => DeliveryModel.fromJson(json))
            .toList();
      }
      throw Exception(json.decode(response.body)['message']);
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<DeliveryModel> createDelivery(
      {required Point origin,
      required Point destination,
      required int price,
      required String vehicle}) async {
    String? userId = await UserSession.getUserId();

    try {
      Response response = await post(
        Uri.parse('$baseUrlApi/deliveries/create/$userId'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "origin": origin.toJson(),
          "destination": destination.toJson(),
          "price": price,
          "vehicle": vehicle
        }),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return DeliveryModel.fromJson(responseData);
      }
      throw Exception(json.decode(response.body)['message']);
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<DeliveryModel> getDeliveryById(
      {required String? deliveryId}) async {
    try {
      Response response =
          await get(Uri.parse('$baseUrlApi/deliveries/get/$deliveryId'));
      if (response.statusCode == 200) {
        dynamic delivery = json.decode(response.body);
        return DeliveryModel.fromJson(delivery);
      }

      throw Exception(json.decode(response.body)['message']);
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<bool> checkIfDeliveryExists(
      {required String? deliveryId}) async {
    try {
      Response response =
          await get(Uri.parse('$baseUrlApi/deliveries/get/$deliveryId'));
      if (response.statusCode == 200) {
        return true;
      }

      if (response.statusCode == 404) {
        return false;
      }
      throw Exception(json.decode(response.body)['message']);
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future cancelDelivery({required String? deliveryId}) async {
    try {
      await delete(Uri.parse('$baseUrlApi/deliveries/delete/$deliveryId'));
    } catch (e) {
      throw Exception("cancelDelivery: $e");
    }
  }

  static Future<int> getDeliveryPrice({
    required int distance,
    required int duration,
  }) async {
    try {
      Response response = await get(Uri.parse(
          '$baseUrlApi/deliveries/price?distance=$distance&duration=$duration'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception(json.decode(response.body)['message']);
    } catch (e) {
      throw Exception(e);
    }
  }
}

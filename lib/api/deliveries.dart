import 'dart:convert';
import 'package:be_fast/models/custom/custom.dart';
import 'package:http/http.dart';

import 'package:be_fast/utils/user_session.dart';
import 'package:be_fast/models/delivery.dart';
import 'package:be_fast/api/constants/base_url.dart';

class DeliveriesAPI {
  Future<List<DeliveryModel>> getUserDeliveries(
      {required String userId}) async {
    try {
      Response response =
          await get(Uri.parse('$baseUrlApi/deliveries/users/$userId'));

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

  Future<List<DeliveryModel>> getCourierDeliveries(
      {required String courierId}) async {
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

  Future<DeliveryModel> createDelivery({
    required Point origin,
    required Point destination,
    required int price,
  }) async {
    String? userId = await UserSession.getUserId();

    try {
      Response response = await post(
        Uri.parse('$baseUrlApi/deliveries/create/$userId'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "origin": origin,
          "destination": destination,
          "price": price,
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

  Future<DeliveryModel> getDeliveryById({required String deliveryId}) async {
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

  Future<int> getDeliveryPrice({
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

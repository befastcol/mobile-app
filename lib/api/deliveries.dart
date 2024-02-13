import 'dart:convert';
import 'package:http/http.dart';

import 'package:be_fast/utils/user_session.dart';
import 'package:be_fast/models/delivery.dart';
import 'package:be_fast/models/location.dart';
import 'package:be_fast/api/constants/base_url.dart';

class DeliveriesAPI {
  Future<List<Delivery>> getUserDeliveries({required String userId}) async {
    try {
      Response response =
          await get(Uri.parse('$baseUrl/deliveries/users/$userId'));
      if (response.statusCode == 200) {
        List<dynamic> deliveryList = json.decode(response.body);
        return deliveryList.map((json) => Delivery.fromJson(json)).toList();
      }
      throw Exception(json.decode(response.body)['message']);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<Delivery>> getCourierDeliveries(
      {required String courierId}) async {
    try {
      Response response =
          await get(Uri.parse('$baseUrl/deliveries/couriers/$courierId'));
      if (response.statusCode == 200) {
        List<dynamic> deliveryList = json.decode(response.body);
        return deliveryList.map((json) => Delivery.fromJson(json)).toList();
      }
      throw Exception(json.decode(response.body)['message']);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<Delivery> createDelivery({
    required LocationModel origin,
    required LocationModel destination,
    required int price,
  }) async {
    String? userId = await UserSession.getUserId();

    try {
      Response response = await post(
        Uri.parse('$baseUrl/deliveries/create/$userId'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "origin": origin,
          "destination": destination,
          "price": price,
        }),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return Delivery.fromJson(responseData);
      }
      throw Exception(json.decode(response.body)['message']);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<Delivery> getDeliveryById({required String deliveryId}) async {
    try {
      Response response =
          await get(Uri.parse('$baseUrl/deliveries/$deliveryId'));
      if (response.statusCode == 200) {
        dynamic delivery = json.decode(response.body);
        return Delivery.fromJson(delivery);
      }
      throw Exception(json.decode(response.body)['message']);
    } catch (e) {
      throw Exception(e);
    }
  }
}

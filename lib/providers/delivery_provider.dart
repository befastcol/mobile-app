import 'package:flutter/material.dart';

import '../api/deliveries.dart';
import '../api/users.dart';
import '../models/custom/custom.dart';
import '../models/delivery.dart';
import '../models/user.dart';
import '../shared/utils/user_session.dart';

class DeliveryProvider extends ChangeNotifier {
  String _id = '';
  String? _courier = '';
  String _status = '';

  Point _origin = Point();
  Point _destination = Point();
  int _price = 0;

  bool _isLoadingDeliveryDetails = false;
  bool _isLookingForCouriers = false;

  String get id => _id;
  String? get courier => _courier;
  String get status => _status;

  Point get origin => _origin;
  Point get destination => _destination;
  int get price => _price;

  bool get isLoadingDeliveryDetails => _isLoadingDeliveryDetails;

  bool get isLookingForCouriers => _isLookingForCouriers;

  DeliveryProvider() {
    _initDeliveryOrigin();
  }

  Future _initDeliveryOrigin() async {
    String? userId = await UserSession.getUserId();
    UserModel user = await UsersAPI.getUser(userId: userId);

    _origin = user.originLocation;
    notifyListeners();
  }

  Future createDelivery() async {
    try {
      _isLookingForCouriers = true;
      notifyListeners();

      DeliveryModel delivery = await DeliveriesAPI.createDelivery(
          origin: _origin, destination: _destination, price: _price);
      initDeliveryValues(delivery);
    } catch (e) {
      debugPrint("createDelivery: $e");
    }
  }

  Future<void> cancelDelivery({
    required Function onSuccess,
    required Function onError,
  }) async {
    try {
      await DeliveriesAPI.cancelDelivery(deliveryId: _id);
      onSuccess();
    } catch (e) {
      onError();
      debugPrint("cancelDelivery: $e");
    }
  }

  Future getDeliveryPrice(int distance, int duration) async {
    _price = await DeliveriesAPI.getDeliveryPrice(
        distance: distance, duration: duration);
    notifyListeners();
  }

  void initDeliveryValues(DeliveryModel delivery) {
    _id = delivery.id;
    _courier = delivery.courier;
    _status = delivery.status;
    notifyListeners();
  }

  void updateDeliveryOrigin(Point origin) {
    _origin = origin;
    notifyListeners();
  }

  void updateDeliveryDestination(Point destination) {
    _destination = destination;
    notifyListeners();
  }

  void updateDeliveryPrice(int price) {
    _price = price;
    notifyListeners();
  }

  void setIsLoadingDeliveryDetails(bool value) {
    _isLoadingDeliveryDetails = value;
    notifyListeners();
  }

  void setIsLookingForCouriers(bool value) {
    _isLookingForCouriers = value;
    notifyListeners();
  }
}

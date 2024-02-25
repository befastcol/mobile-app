import 'package:be_fast/models/custom/custom.dart';

class DeliveryModel {
  final String id, status;
  final String? courier;
  final int price;
  final Point origin, destination;
  final List<double> currentLocation;
  final DateTime requestedDate;
  final DateTime? deliveredDate;

  DeliveryModel(
      {required this.id,
      required this.requestedDate,
      required this.origin,
      required this.destination,
      required this.currentLocation,
      required this.price,
      required this.status,
      this.deliveredDate,
      this.courier});

  factory DeliveryModel.fromJson(Map<String, dynamic> json) {
    return DeliveryModel(
      id: json['_id'],
      requestedDate: DateTime.parse(json['requestedDate']),
      origin: Point.fromJson(json['origin']),
      destination: Point.fromJson(json['destination']),
      currentLocation: List<double>.from(json['currentLocation']),
      price: json['price'],
      status: json['status'],
      courier: json['courier'],
      deliveredDate: json['deliveredDate'] != null
          ? DateTime.parse(json['deliveredDate'])
          : null,
    );
  }
}

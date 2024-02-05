import 'package:be_fast/models/location.dart';

class Delivery {
  final String id, status;
  final String? courier;
  final int price;
  final Location origin, destination;
  final DateTime requestedDate;
  final DateTime? deliveredDate;

  Delivery(
      {required this.id,
      required this.requestedDate,
      required this.origin,
      required this.destination,
      required this.price,
      required this.status,
      this.deliveredDate,
      this.courier});

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['_id'],
      requestedDate: DateTime.parse(json['requestedDate']),
      origin: Location.fromJson(json['origin']),
      destination: Location.fromJson(json['destination']),
      price: json['price'],
      status: json['status'],
      courier: json['courier'],
      deliveredDate: json['deliveredDate'] != null
          ? DateTime.parse(json['deliveredDate'])
          : null,
    );
  }
}

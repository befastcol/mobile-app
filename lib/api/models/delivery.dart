import 'package:be_fast/api/models/location.dart';

class Delivery {
  final String id;
  final DateTime requestedDate;
  final Location origin;
  final Location destination;
  final double price;
  final String status;

  Delivery({
    required this.id,
    required this.requestedDate,
    required this.origin,
    required this.destination,
    required this.price,
    required this.status,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['_id'],
      requestedDate: DateTime.parse(json['requestedDate']),
      origin: Location.fromJson(json['origin']),
      destination: Location.fromJson(json['destination']),
      price: (json['price'] as num).toDouble(),
      status: json['status'],
    );
  }
}

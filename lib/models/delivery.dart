import 'package:be_fast/models/custom/custom.dart';

class DeliveryModel {
  final String id, status;
  final String? courier;
  final int price;
  final Point origin, destination;
  final DateTime requestedDate;
  final DateTime? deliveredDate;

  DeliveryModel(
      {required this.id,
      required this.requestedDate,
      required this.origin,
      required this.destination,
      required this.price,
      required this.status,
      this.deliveredDate,
      this.courier});

  factory DeliveryModel.fromJson(dynamic json) {
    return DeliveryModel(
      id: json['_id'],
      requestedDate: DateTime.parse(json['requestedDate']),
      origin: Point.fromJson(json['origin']),
      destination: Point.fromJson(json['destination']),
      price: json['price'],
      status: json['status'],
      courier: json['courier'] ?? '',
      deliveredDate: json['deliveredDate'] != null
          ? DateTime.parse(json['deliveredDate'])
          : null,
    );
  }

  DeliveryModel copyWith({
    String? id,
    String? status,
    String? courier,
    int? price,
    Point? origin,
    Point? destination,
    DateTime? requestedDate,
    DateTime? deliveredDate,
  }) {
    return DeliveryModel(
      id: id ?? this.id,
      status: status ?? this.status,
      courier: courier ?? this.courier,
      price: price ?? this.price,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      requestedDate: requestedDate ?? this.requestedDate,
      deliveredDate: deliveredDate ?? this.deliveredDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'requestedDate': requestedDate.toIso8601String(),
      'origin': origin.toJson(),
      'destination': destination.toJson(),
      'price': price,
      'status': status,
      'courier': courier,
      'deliveredDate': deliveredDate?.toIso8601String(),
    };
  }
}

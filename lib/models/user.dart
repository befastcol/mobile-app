import 'package:be_fast/models/custom/custom.dart';

class UserModel {
  final String name, phone, status, vehicle, role, id;
  final Documents documents;
  final int credits;
  final Point? currentLocation;
  final Point originLocation;
  final bool isDisabled;

  UserModel({
    required this.id,
    this.name = '',
    required this.phone,
    this.credits = 0,
    this.role = 'user',
    required this.documents,
    this.currentLocation,
    required this.originLocation,
    this.isDisabled = false,
    this.status = 'inactive',
    this.vehicle = 'motorcycle',
  });

  factory UserModel.fromJson(dynamic json) {
    return UserModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'user',
      credits: json['credits'] ?? 0,
      documents: Documents.fromJson(json['documents']),
      currentLocation: Point.fromJson(json['currentLocation']),
      originLocation: Point.fromJson(json['originLocation']),
      isDisabled: json['isDisabled'] ?? false,
      status: json['status'] ?? 'inactive',
      vehicle: json['vehicle'] ?? 'motorcycle',
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? role,
    Documents? documents,
    Point? currentLocation,
    Point? originLocation,
    bool? isDisabled,
    String? status,
    String? vehicle,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      documents: documents ?? this.documents,
      currentLocation: currentLocation ?? this.currentLocation,
      originLocation: originLocation ?? this.originLocation,
      isDisabled: isDisabled ?? this.isDisabled,
      status: status ?? this.status,
      vehicle: vehicle ?? this.vehicle,
    );
  }
}

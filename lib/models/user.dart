import 'package:be_fast/models/location.dart';

class UserModel {
  final String id, name, phone, role;
  final LocationModel? originLocation;

  UserModel(
      {required this.id,
      required this.name,
      required this.phone,
      required this.role,
      this.originLocation});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'],
      name: json['name'],
      phone: json['phone'],
      role: json['role'],
      originLocation: LocationModel.fromJson(json['originLocation']),
    );
  }
}

class CreateUserResponse {
  final String userId;
  final bool alreadyExists;

  CreateUserResponse({required this.userId, required this.alreadyExists});
}

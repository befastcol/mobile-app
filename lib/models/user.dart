import 'package:be_fast/models/location.dart';

class UserModel {
  final String id, name, phone, role;
  final LocationModel originLocation;

  UserModel(
      {required this.id,
      required this.name,
      required this.phone,
      required this.role,
      required this.originLocation});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    var originLocationJson = json['originLocation'];
    var originLocation = originLocationJson != null
        ? LocationModel.fromJson(originLocationJson)
        : LocationModel(title: '', subtitle: '', coordinates: []);

    return UserModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      originLocation: originLocation,
    );
  }
}

class CreateUserResponse {
  final String userId;
  final bool alreadyExists;

  CreateUserResponse({required this.userId, required this.alreadyExists});
}

class UserModel {
  final String id, name, phone, role;

  UserModel(
      {required this.id,
      required this.name,
      required this.phone,
      required this.role});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'],
      name: json['name'],
      phone: json['phone'],
      role: json['role'],
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
    );
  }
}

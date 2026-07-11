import '../../domain/entities/user_entity.dart';

class UserModel {
  String id;
  String? email;
  String? phone;
  String? name;
  String? imageUrl;
  String? username;
  String? role;
  bool? isActive;
  String? createdAt;
  String? updatedAt;

  UserModel({
    required this.id,
    this.email,
    this.phone,
    this.name,
    this.imageUrl,
    this.username,
    this.role,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final firstName = json['first_name'];
    final lastName = json['last_name'];
    final fallbackName = [firstName, lastName].whereType<String>().where((s) => s.isNotEmpty).join(' ');

    return UserModel(
      id: json['id'].toString(),
      email: json['email'],
      phone: json['phone'],
      name: json['name'] ?? (fallbackName.isNotEmpty ? fallbackName : null),
      imageUrl: json['imageUrl'] ?? json['photo'],
      username: json['username'],
      role: json['role'],
      isActive: json['is_active'] is bool ? json['is_active'] as bool : null,
      createdAt: json['createdAt'] ?? json['created_at'],
      updatedAt: json['updatedAt'] ?? json['updated_at'],
    );
  }

  /// Local SQLite persistence shape. Deliberately excludes [username], [role]
  /// and [isActive]: the local `User` table only ever caches the signed-in
  /// user's own profile, whose schema doesn't carry those columns.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'name': name,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      phone: entity.phone,
      name: entity.name,
      imageUrl: entity.imageUrl,
      username: entity.username,
      role: entity.role,
      isActive: entity.isActive,
      createdAt: entity.createdAt ?? DateTime.now().toIso8601String(),
      updatedAt: entity.updatedAt ?? DateTime.now().toIso8601String(),
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      phone: phone,
      name: name,
      imageUrl: imageUrl,
      username: username,
      role: role,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

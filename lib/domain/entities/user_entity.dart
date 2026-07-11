import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String? email;
  final String? phone;
  final String? name;
  final String? imageUrl;
  final String? username;
  final String? role;
  final bool? isActive;
  final String? createdAt;
  final String? updatedAt;

  const UserEntity({
    required this.id,
    this.phone,
    this.email,
    this.name,
    this.imageUrl,
    this.username,
    this.role,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  bool get isAdmin => role == 'admin';

  UserEntity copyWith({
    String? id,
    String? phone,
    String? email,
    String? name,
    String? imageUrl,
    String? username,
    String? role,
    bool? isActive,
    String? createdAt,
    String? updatedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      username: username ?? this.username,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    phone,
    name,
    imageUrl,
    username,
    role,
    isActive,
    createdAt,
    updatedAt,
  ];
}

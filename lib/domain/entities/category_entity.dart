import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final int id;
  final String name;
  final String? description;
  final int productCount;
  final String? createdAt;
  final String? updatedAt;

  const CategoryEntity({
    required this.id,
    required this.name,
    this.description,
    required this.productCount,
    this.createdAt,
    this.updatedAt,
  });

  CategoryEntity copyWith({
    int? id,
    String? name,
    String? description,
    int? productCount,
    String? createdAt,
    String? updatedAt,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      productCount: productCount ?? this.productCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, description, productCount, createdAt, updatedAt];
}

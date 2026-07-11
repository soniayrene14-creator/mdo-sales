import '../../domain/entities/category_entity.dart';

class CategoryModel {
  int id;
  String name;
  String? description;
  int productCount;
  String? createdAt;
  String? updatedAt;

  CategoryModel({
    required this.id,
    required this.name,
    this.description,
    required this.productCount,
    this.createdAt,
    this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      productCount: json['product_count'] ?? 0,
      createdAt: json['createdAt'] ?? json['created_at'],
      updatedAt: json['updatedAt'] ?? json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'product_count': productCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      productCount: entity.productCount,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      description: description,
      productCount: productCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

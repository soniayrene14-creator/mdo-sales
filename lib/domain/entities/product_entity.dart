import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final int? id;
  final String createdById;
  final String name;
  final String imageUrl;
  final int stock;
  final int? sold;
  final int price;
  final String? description;
  final int? categoryId;
  final String? categoryName;
  final String? createdAt;
  final String? updatedAt;
  final String? stockStatus;
  final bool? isActive;

  const ProductEntity({
    this.id,
    required this.createdById,
    required this.name,
    required this.imageUrl,
    required this.stock,
    this.sold,
    required this.price,
    this.description,
    this.categoryId,
    this.categoryName,
    this.createdAt,
    this.updatedAt,
    this.stockStatus,
    this.isActive,
  });

  ProductEntity copyWith({
    int? id,
    String? createdById,
    String? name,
    String? imageUrl,
    int? stock,
    int? sold,
    int? price,
    String? description,
    int? categoryId,
    String? categoryName,
    String? createdAt,
    String? updatedAt,
    String? stockStatus,
    bool? isActive,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      createdById: createdById ?? this.createdById,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      stock: stock ?? this.stock,
      sold: sold ?? this.sold,
      price: price ?? this.price,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      stockStatus: stockStatus ?? this.stockStatus,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
    id,
    createdById,
    name,
    imageUrl,
    stock,
    sold,
    price,
    description,
    categoryId,
    categoryName,
    createdAt,
    updatedAt,
    stockStatus,
    isActive,
  ];
}

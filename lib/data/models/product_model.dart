import '../../domain/entities/product_entity.dart';

class ProductModel {
  int id;
  String createdById;
  String name;
  String imageUrl;
  int stock;
  int sold;
  int price;
  String? description;
  String? createdAt;
  String? updatedAt;
  String? reference;
  int? categoryId;
  String? categoryName;
  int? lowStockThreshold;
  String? stockStatus;
  bool? isActive;
  String? image;

  ProductModel({
    required this.id,
    required this.createdById,
    required this.name,
    required this.imageUrl,
    required this.stock,
    required this.sold,
    required this.price,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.reference,
    this.categoryId,
    this.categoryName,
    this.lowStockThreshold,
    this.stockStatus,
    this.isActive,
    this.image,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final priceRaw = json['price'];
    final priceInt = priceRaw != null ? double.parse(priceRaw.toString()).toInt() : 0;

    return ProductModel(
      id: json['id'],
      createdById: json['createdById']?.toString() ?? '',
      name: json['name'],
      imageUrl: json['imageUrl'] ?? json['image'] ?? '',
      stock: json['stock'] ?? json['quantity'] ?? 0,
      sold: json['sold'] ?? 0,
      price: priceInt,
      description: json['description'],
      createdAt: json['createdAt'] ?? json['created_at'],
      updatedAt: json['updatedAt'] ?? json['updated_at'],
      reference: json['reference'],
      categoryId: json['category'] is int ? json['category'] as int : int.tryParse(json['category']?.toString() ?? ''),
      categoryName: json['category_name'],
      lowStockThreshold: json['low_stock_threshold'],
      stockStatus: json['stock_status'],
      isActive: switch (json['is_active']) {
        bool value => value,
        int value => value == 1,
        _ => null,
      },
      image: json['image'] ?? json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdById': createdById,
      'name': name,
      'imageUrl': imageUrl,
      'image': image,
      'stock': stock,
      'quantity': stock,
      'sold': sold,
      'price': price,
      'description': description,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'reference': reference,
      'category': categoryId,
      'category_name': categoryName,
      'low_stock_threshold': lowStockThreshold,
      'stock_status': stockStatus,
      'is_active': isActive == null ? null : (isActive! ? 1 : 0),
    };
  }

  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id ?? DateTime.now().millisecondsSinceEpoch,
      createdById: entity.createdById,
      name: entity.name,
      imageUrl: entity.imageUrl,
      stock: entity.stock,
      sold: entity.sold ?? 0,
      price: entity.price,
      description: entity.description,
      createdAt: entity.createdAt ?? DateTime.now().toIso8601String(),
      updatedAt: entity.updatedAt ?? DateTime.now().toIso8601String(),
      reference: null,
      categoryId: entity.categoryId,
      categoryName: entity.categoryName,
      lowStockThreshold: null,
      stockStatus: null,
      isActive: entity.isActive,
      image: null,
    );
  }

  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      createdById: createdById,
      name: name,
      imageUrl: imageUrl,
      stock: stock,
      sold: sold,
      price: price,
      description: description,
      categoryId: categoryId,
      categoryName: categoryName,
      createdAt: createdAt,
      updatedAt: updatedAt,
      stockStatus: stockStatus,
      isActive: isActive,
    );
  }
}

import '../../domain/entities/ordered_product_entity.dart';

class OrderedProductModel {
  int id;
  int transactionId;
  int productId;
  int quantity;
  int stock;
  String name;
  String imageUrl;
  int price;
  String? createdAt;
  String? updatedAt;

  OrderedProductModel({
    required this.id,
    required this.transactionId,
    required this.productId,
    required this.quantity,
    required this.stock,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.createdAt,
    this.updatedAt,
  });

  /// The backend's SaleItemSerializer returns a different shape than the
  /// local table (`product`/`product_name` instead of `productId`/`name`,
  /// and no `transactionId`, `stock` or `imageUrl` at all since those belong
  /// to the product, not the sale item). Every field needs a fallback so
  /// parsing a remotely-fetched sale doesn't crash on the missing keys.
  factory OrderedProductModel.fromJson(Map<String, dynamic> json) {
    final priceRaw = json['price'] ?? json['unit_price'];
    final priceInt = priceRaw != null ? double.parse(priceRaw.toString()).toInt() : 0;

    return OrderedProductModel(
      id: json['id'],
      transactionId: json['transactionId'] ?? 0,
      productId: json['productId'] ?? json['product'] ?? 0,
      quantity: json['quantity'],
      stock: json['stock'] ?? 0,
      name: json['name'] ?? json['product_name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      price: priceInt,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transactionId': transactionId,
      'productId': productId,
      'quantity': quantity,
      'stock': stock,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'unit_price': price,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory OrderedProductModel.fromEntity(OrderedProductEntity entity) {
    return OrderedProductModel(
      id: entity.id ?? DateTime.now().millisecondsSinceEpoch,
      transactionId: entity.transactionId ?? DateTime.now().millisecondsSinceEpoch,
      productId: entity.productId,
      quantity: entity.quantity,
      stock: entity.stock,
      name: entity.name,
      imageUrl: entity.imageUrl,
      price: entity.price,
      createdAt: entity.createdAt ?? DateTime.now().toIso8601String(),
      updatedAt: entity.updatedAt ?? DateTime.now().toIso8601String(),
    );
  }

  OrderedProductEntity toEntity() {
    return OrderedProductEntity(
      id: id,
      transactionId: transactionId,
      productId: productId,
      quantity: quantity,
      stock: stock,
      name: name,
      imageUrl: imageUrl,
      price: price,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

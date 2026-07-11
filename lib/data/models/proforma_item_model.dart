import '../../domain/entities/proforma_entity.dart';
import '../../domain/entities/proforma_item_entity.dart';

class ProformaItemModel {
  int id;
  int productId;
  String productName;
  int quantity;
  int unitPrice;
  int subtotal;

  ProformaItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory ProformaItemModel.fromJson(Map<String, dynamic> json) {
    final priceRaw = json['unit_price'] ?? json['price'];
    final priceInt = priceRaw != null ? double.parse(priceRaw.toString()).toInt() : 0;
    final subtotalRaw = json['subtotal'];
    final subtotalInt = subtotalRaw != null ? double.parse(subtotalRaw.toString()).toInt() : 0;

    return ProformaItemModel(
      id: json['id'] ?? 0,
      productId: json['product'] ?? json['productId'] ?? 0,
      productName: json['product_name'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: priceInt,
      subtotal: subtotalInt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'subtotal': subtotal,
    };
  }

  factory ProformaItemModel.fromEntity(ProformaItemEntity entity) {
    return ProformaItemModel(
      id: entity.id,
      productId: entity.productId,
      productName: entity.productName,
      quantity: entity.quantity,
      unitPrice: entity.unitPrice,
      subtotal: entity.subtotal,
    );
  }

  ProformaItemEntity toEntity() {
    return ProformaItemEntity(
      id: id,
      productId: productId,
      productName: productName,
      quantity: quantity,
      unitPrice: unitPrice,
      subtotal: subtotal,
    );
  }
}

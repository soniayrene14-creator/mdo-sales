import '../../domain/entities/stock_movement_entity.dart';

class StockMovementModel {
  int id;
  int productId;
  String productName;
  String movementType;
  int quantity;
  String? reason;
  int createdById;
  String? createdByName;
  String? createdAt;

  StockMovementModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.movementType,
    required this.quantity,
    this.reason,
    required this.createdById,
    this.createdByName,
    this.createdAt,
  });

  factory StockMovementModel.fromJson(Map<String, dynamic> json) {
    return StockMovementModel(
      id: json['id'] ?? 0,
      productId: json['product'] ?? 0,
      productName: json['product_name'] ?? '',
      movementType: json['movement_type'] ?? '',
      quantity: json['quantity'] ?? 0,
      reason: json['reason'],
      createdById: json['created_by'] ?? 0,
      createdByName: json['created_by_name'],
      createdAt: json['createdAt'] ?? json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': productId,
      'product_name': productName,
      'movement_type': movementType,
      'quantity': quantity,
      'reason': reason,
      'created_by': createdById,
      'created_by_name': createdByName,
      'createdAt': createdAt,
    };
  }

  factory StockMovementModel.fromEntity(StockMovementEntity entity) {
    return StockMovementModel(
      id: entity.id,
      productId: entity.productId,
      productName: entity.productName,
      movementType: entity.movementType,
      quantity: entity.quantity,
      reason: entity.reason,
      createdById: entity.createdById,
      createdByName: entity.createdByName,
      createdAt: entity.createdAt,
    );
  }

  StockMovementEntity toEntity() {
    return StockMovementEntity(
      id: id,
      productId: productId,
      productName: productName,
      movementType: movementType,
      quantity: quantity,
      reason: reason,
      createdById: createdById,
      createdByName: createdByName,
      createdAt: createdAt,
    );
  }
}

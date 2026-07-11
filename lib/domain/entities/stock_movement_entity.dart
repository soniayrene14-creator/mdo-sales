import 'package:equatable/equatable.dart';

class StockMovementEntity extends Equatable {
  final int id;
  final int productId;
  final String productName;
  final String movementType;
  final int quantity;
  final String? reason;
  final int createdById;
  final String? createdByName;
  final String? createdAt;

  const StockMovementEntity({
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

  @override
  List<Object?> get props => [id, productId, productName, movementType, quantity, reason, createdById, createdByName, createdAt];
}

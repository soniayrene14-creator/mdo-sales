import 'package:equatable/equatable.dart';

class SaleItemEntity extends Equatable {
  final int id;
  final int productId;
  final String productName;
  final int quantity;
  final int unitPrice;
  final int subtotal;

  const SaleItemEntity({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  @override
  List<Object?> get props => [id, productId, productName, quantity, unitPrice, subtotal];
}

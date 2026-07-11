import 'package:equatable/equatable.dart';
import 'sale_item_entity.dart';

class SaleEntity extends Equatable {
  final int id;
  final String saleNumber;
  final int sellerId;
  final String? sellerName;
  final String? customerName;
  final String? customerPhone;
  final String paymentMethod;
  final List<SaleItemEntity> items;
  final int totalAmount;
  final String? createdAt;

  const SaleEntity({
    required this.id,
    required this.saleNumber,
    required this.sellerId,
    this.sellerName,
    this.customerName,
    this.customerPhone,
    required this.paymentMethod,
    required this.items,
    required this.totalAmount,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, saleNumber, sellerId, sellerName, customerName, customerPhone, paymentMethod, items, totalAmount, createdAt];
}

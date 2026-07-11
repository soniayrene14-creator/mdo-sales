import 'package:equatable/equatable.dart';
import 'proforma_item_entity.dart';

class ProformaEntity extends Equatable {
  final int id;
  final String proformaNumber;
  final int sellerId;
  final String? sellerName;
  final String? customerName;
  final String? customerPhone;
  final List<ProformaItemEntity> items;
  final int totalAmount;
  final String? createdAt;

  const ProformaEntity({
    required this.id,
    required this.proformaNumber,
    required this.sellerId,
    this.sellerName,
    this.customerName,
    this.customerPhone,
    required this.items,
    required this.totalAmount,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, proformaNumber, sellerId, sellerName, customerName, customerPhone, items, totalAmount, createdAt];
}

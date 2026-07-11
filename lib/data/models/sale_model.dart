import '../../domain/entities/sale_entity.dart';
import 'sale_item_model.dart';

class SaleModel {
  int id;
  String saleNumber;
  int sellerId;
  String? sellerName;
  String? customerName;
  String? customerPhone;
  String paymentMethod;
  List<SaleItemModel> items;
  int totalAmount;
  String? createdAt;

  SaleModel({
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

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    final totalRaw = json['totalAmount'] ?? json['total_amount'];
    final totalInt = totalRaw != null ? double.parse(totalRaw.toString()).toInt() : 0;

    final itemsJson = json['items'] as List<dynamic>? ?? [];
    return SaleModel(
      id: json['id'] ?? 0,
      saleNumber: json['saleNumber'] ?? json['sale_number'] ?? '',
      sellerId: json['seller'] ?? 0,
      sellerName: json['sellerName'] ?? json['seller_name'],
      customerName: json['customerName'] ?? json['customer_name'],
      customerPhone: json['customerPhone'] ?? json['customer_phone'],
      paymentMethod: json['paymentMethod'] ?? json['payment_method'] ?? '',
      items: itemsJson.map((e) => SaleItemModel.fromJson(e as Map<String, dynamic>)).toList(),
      totalAmount: totalInt,
      createdAt: json['createdAt'] ?? json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'saleNumber': saleNumber,
      'sale_number': saleNumber,
      'seller': sellerId,
      'sellerName': sellerName,
      'seller_name': sellerName,
      'customerName': customerName,
      'customer_name': customerName,
      'customerPhone': customerPhone,
      'customer_phone': customerPhone,
      'paymentMethod': paymentMethod,
      'payment_method': paymentMethod,
      'items': items.map((e) => e.toJson()).toList(),
      'totalAmount': totalAmount,
      'total_amount': totalAmount,
      'createdAt': createdAt,
      'created_at': createdAt,
    };
  }

  factory SaleModel.fromEntity(SaleEntity entity) {
    return SaleModel(
      id: entity.id,
      saleNumber: entity.saleNumber,
      sellerId: entity.sellerId,
      sellerName: entity.sellerName,
      customerName: entity.customerName,
      customerPhone: entity.customerPhone,
      paymentMethod: entity.paymentMethod,
      items: entity.items.map((e) => SaleItemModel.fromEntity(e)).toList(),
      totalAmount: entity.totalAmount,
      createdAt: entity.createdAt,
    );
  }

  SaleEntity toEntity() {
    return SaleEntity(
      id: id,
      saleNumber: saleNumber,
      sellerId: sellerId,
      sellerName: sellerName,
      customerName: customerName,
      customerPhone: customerPhone,
      paymentMethod: paymentMethod,
      items: items.map((e) => e.toEntity()).toList(),
      totalAmount: totalAmount,
      createdAt: createdAt,
    );
  }
}

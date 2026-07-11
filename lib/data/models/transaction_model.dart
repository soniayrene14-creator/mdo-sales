import '../../domain/entities/transaction_entity.dart';
import 'ordered_product_model.dart';
import 'user_model.dart';

int? _parseAmount(dynamic raw) {
  return raw != null ? double.parse(raw.toString()).toInt() : null;
}

class TransactionModel {
  int id;
  String paymentMethod;
  String? customerName;
  String? customerPhone;
  String? description;
  String createdById;
  UserModel? createdBy;
  List<OrderedProductModel>? orderedProducts;
  int? receivedAmount;
  int? returnAmount;
  int totalAmount;
  int? totalOrderedProduct;
  String? saleNumber;
  String? sellerName;
  String? createdAt;
  String? updatedAt;

  TransactionModel({
    required this.id,
    required this.paymentMethod,
    this.customerName,
    this.customerPhone,
    this.description,
    required this.createdById,
    this.createdBy,
    this.orderedProducts,
    this.receivedAmount,
    this.returnAmount,
    required this.totalAmount,
    this.totalOrderedProduct,
    this.saleNumber,
    this.sellerName,
    this.createdAt,
    this.updatedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final totalAmountRaw = json['totalAmount'] ?? json['total_amount'];
    final totalAmountInt = totalAmountRaw == null ? 0 : double.parse(totalAmountRaw.toString()).toInt();

    final items = json['items'];
    final orderedProducts = items is List
        ? (items as List).map((e) => OrderedProductModel.fromJson(e as Map<String, dynamic>)).toList()
        : null;

    return TransactionModel(
      id: json['id'],
      paymentMethod: json['paymentMethod'] ?? json['payment_method'] ?? '',
      customerName: json['customerName'] ?? json['customer_name'],
      customerPhone: json['customer_phone'],
      description: json['description'],
      createdById: json['createdById']?.toString() ?? json['seller']?.toString() ?? '',
      createdBy: json['createdBy'] != null ? UserModel.fromJson(json['createdBy'] as Map<String, dynamic>) : null,
      orderedProducts: orderedProducts,
      receivedAmount: _parseAmount(json['receivedAmount'] ?? json['received_amount']),
      returnAmount: _parseAmount(json['returnAmount'] ?? json['return_amount']),
      totalAmount: totalAmountInt,
      totalOrderedProduct: json['totalOrderedProduct'] ?? orderedProducts?.length,
      saleNumber: json['saleNumber'] ?? json['sale_number'],
      sellerName: json['sellerName'] ?? json['seller_name'],
      createdAt: json['createdAt'] ?? json['created_at'],
      updatedAt: json['updatedAt'] ?? json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paymentMethod': paymentMethod,
      'customerName': customerName,
      'customer_phone': customerPhone,
      'description': description,
      'createdById': createdById,
      'createdBy': createdBy,
      'items': orderedProducts?.map((e) => e.toJson()).toList(),
      'orderedProducts': orderedProducts?.map((e) => e.toJson()).toList(),
      'receivedAmount': receivedAmount,
      'returnAmount': returnAmount,
      'totalAmount': totalAmount,
      'totalOrderedProduct': totalOrderedProduct,
      'sale_number': saleNumber,
      'seller_name': sellerName,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id ?? DateTime.now().millisecondsSinceEpoch,
      paymentMethod: entity.paymentMethod,
      customerName: entity.customerName,
      customerPhone: entity.customerPhone,
      description: entity.description,
      createdById: entity.createdById,
      createdBy: entity.createdBy != null ? UserModel.fromEntity(entity.createdBy!) : null,
      orderedProducts: entity.orderedProducts?.map((e) => OrderedProductModel.fromEntity(e)).toList(),
      receivedAmount: entity.receivedAmount,
      returnAmount: entity.returnAmount,
      totalAmount: entity.totalAmount,
      totalOrderedProduct: entity.totalOrderedProduct,
      saleNumber: null,
      sellerName: null,
      createdAt: entity.createdAt ?? DateTime.now().toIso8601String(),
      updatedAt: entity.updatedAt ?? DateTime.now().toIso8601String(),
    );
  }

  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      paymentMethod: paymentMethod,
      customerName: customerName,
      customerPhone: customerPhone,
      description: description,
      createdBy: createdBy?.toEntity(),
      createdById: createdById,
      orderedProducts: orderedProducts?.map((e) => e.toEntity()).toList(),
      receivedAmount: receivedAmount ?? 0,
      returnAmount: returnAmount ?? 0,
      totalAmount: totalAmount,
      totalOrderedProduct: totalOrderedProduct ?? 0,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

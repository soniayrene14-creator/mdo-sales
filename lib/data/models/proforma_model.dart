import '../../domain/entities/proforma_entity.dart';
import 'proforma_item_model.dart';

class ProformaModel {
  int id;
  String proformaNumber;
  int sellerId;
  String? sellerName;
  String? customerName;
  String? customerPhone;
  List<ProformaItemModel> items;
  int totalAmount;
  String? createdAt;

  ProformaModel({
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

  factory ProformaModel.fromJson(Map<String, dynamic> json) {
    final totalRaw = json['totalAmount'] ?? json['total_amount'];
    final totalInt = totalRaw != null ? double.parse(totalRaw.toString()).toInt() : 0;

    final itemsJson = json['items'] as List<dynamic>? ?? [];
    return ProformaModel(
      id: json['id'] ?? 0,
      proformaNumber: json['proformaNumber'] ?? json['proforma_number'] ?? '',
      sellerId: json['seller'] ?? 0,
      sellerName: json['sellerName'] ?? json['seller_name'],
      customerName: json['customerName'] ?? json['customer_name'],
      customerPhone: json['customerPhone'] ?? json['customer_phone'],
      items: itemsJson.map((e) => ProformaItemModel.fromJson(e as Map<String, dynamic>)).toList(),
      totalAmount: totalInt,
      createdAt: json['createdAt'] ?? json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'proformaNumber': proformaNumber,
      'proforma_number': proformaNumber,
      'seller': sellerId,
      'sellerName': sellerName,
      'seller_name': sellerName,
      'customerName': customerName,
      'customer_name': customerName,
      'customerPhone': customerPhone,
      'customer_phone': customerPhone ?? '',
      'items': items.map((e) => e.toJson()).toList(),
      'totalAmount': totalAmount,
      'total_amount': totalAmount,
      'createdAt': createdAt,
      'created_at': createdAt,
    };
  }

  factory ProformaModel.fromEntity(ProformaEntity entity) {
    return ProformaModel(
      id: entity.id,
      proformaNumber: entity.proformaNumber,
      sellerId: entity.sellerId,
      sellerName: entity.sellerName,
      customerName: entity.customerName,
      customerPhone: entity.customerPhone,
      items: entity.items.map((e) => ProformaItemModel.fromEntity(e)).toList(),
      totalAmount: entity.totalAmount,
      createdAt: entity.createdAt,
    );
  }

  ProformaEntity toEntity() {
    return ProformaEntity(
      id: id,
      proformaNumber: proformaNumber,
      sellerId: sellerId,
      sellerName: sellerName,
      customerName: customerName,
      customerPhone: customerPhone,
      items: items.map((e) => e.toEntity()).toList(),
      totalAmount: totalAmount,
      createdAt: createdAt,
    );
  }
}

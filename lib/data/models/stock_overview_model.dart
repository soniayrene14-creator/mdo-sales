import '../../domain/entities/stock_overview_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../models/product_model.dart';

class StockOverviewModel {
  int totalProducts;
  int enStock;
  int stockFaible;
  int rupture;
  List<ProductModel> alertes;

  StockOverviewModel({
    required this.totalProducts,
    required this.enStock,
    required this.stockFaible,
    required this.rupture,
    required this.alertes,
  });

  factory StockOverviewModel.fromJson(Map<String, dynamic> json) {
    final alertesJson = json['alertes'] as List<dynamic>? ?? [];
    return StockOverviewModel(
      totalProducts: json['total_products'] ?? 0,
      enStock: json['en_stock'] ?? 0,
      stockFaible: json['stock_faible'] ?? 0,
      rupture: json['rupture'] ?? 0,
      alertes: alertesJson.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_products': totalProducts,
      'en_stock': enStock,
      'stock_faible': stockFaible,
      'rupture': rupture,
      'alertes': alertes.map((e) => e.toJson()).toList(),
    };
  }

  factory StockOverviewModel.fromEntity(StockOverviewEntity entity) {
    return StockOverviewModel(
      totalProducts: entity.totalProducts,
      enStock: entity.enStock,
      stockFaible: entity.stockFaible,
      rupture: entity.rupture,
      alertes: entity.alertes.map((e) => ProductModel.fromEntity(e)).toList(),
    );
  }

  StockOverviewEntity toEntity() {
    return StockOverviewEntity(
      totalProducts: totalProducts,
      enStock: enStock,
      stockFaible: stockFaible,
      rupture: rupture,
      alertes: alertes.map((e) => e.toEntity()).toList(),
    );
  }
}

import 'package:equatable/equatable.dart';

import '../../domain/entities/product_entity.dart';

class StockOverviewEntity extends Equatable {
  final int totalProducts;
  final int enStock;
  final int stockFaible;
  final int rupture;
  final List<ProductEntity> alertes;

  const StockOverviewEntity({
    required this.totalProducts,
    required this.enStock,
    required this.stockFaible,
    required this.rupture,
    required this.alertes,
  });

  @override
  List<Object?> get props => [totalProducts, enStock, stockFaible, rupture, alertes];
}

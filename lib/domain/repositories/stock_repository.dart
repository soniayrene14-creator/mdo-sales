import '../../../core/common/result.dart';
import '../entities/stock_movement_entity.dart';
import '../entities/stock_overview_entity.dart';

abstract class StockRepository {
  Future<Result<StockOverviewEntity>> getStockOverview();
  Future<Result<StockMovementEntity>> createStockAdjustment(int productId, int quantity, String? reason);
  Future<Result<List<StockMovementEntity>>> getStockMovements({int? product, String? movementType});
}

import '../../../core/common/result.dart';
import '../../../domain/entities/stock_movement_entity.dart';
import '../../../domain/entities/stock_overview_entity.dart';
import '../../../domain/repositories/stock_repository.dart';
import '../models/stock_movement_model.dart';
import '../models/stock_overview_model.dart';
import '../datasources/remote/product_django_remote_datasource_impl.dart';

class StockRepositoryImpl implements StockRepository {
  final ProductDjangoRemoteDataSourceImpl _remoteDataSource;

  StockRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<StockOverviewEntity>> getStockOverview() async {
    final result = await _remoteDataSource.getStockOverview();
    if (result.isFailure) return Result.failure(error: result.error!);
    return Result.success(data: result.data!.toEntity());
  }

  @override
  Future<Result<StockMovementEntity>> createStockAdjustment(int productId, int quantity, String? reason) async {
    final result = await _remoteDataSource.createStockAdjustment(productId, quantity, reason);
    if (result.isFailure) return Result.failure(error: result.error!);
    return Result.success(data: result.data!.toEntity());
  }

  @override
  Future<Result<List<StockMovementEntity>>> getStockMovements({int? product, String? movementType}) async {
    final result = await _remoteDataSource.getStockMovements(product: product, movementType: movementType);
    if (result.isFailure) return Result.failure(error: result.error!);
    final movements = result.data!.map((e) => e.toEntity()).toList();
    return Result.success(data: movements);
  }
}

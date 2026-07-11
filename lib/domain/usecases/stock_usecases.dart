import '../../core/common/result.dart';
import '../../core/usecase/usecase.dart';
import '../../domain/entities/stock_movement_entity.dart';
import '../../domain/entities/stock_overview_entity.dart';
import '../repositories/stock_repository.dart';
import 'params/no_param.dart';

class GetStockOverviewUsecase extends Usecase<Result, NoParam> {
  GetStockOverviewUsecase(this._stockRepository);

  final StockRepository _stockRepository;

  @override
  Future<Result<StockOverviewEntity>> call(NoParam params) async => _stockRepository.getStockOverview();
}

class CreateStockAdjustmentUsecase extends Usecase<Result, StockAdjustmentParams> {
  CreateStockAdjustmentUsecase(this._stockRepository);

  final StockRepository _stockRepository;

  @override
  Future<Result<StockMovementEntity>> call(StockAdjustmentParams params) async =>
      _stockRepository.createStockAdjustment(params.productId, params.quantity, params.reason);
}

class GetStockMovementsUsecase extends Usecase<Result, StockMovementsParams> {
  GetStockMovementsUsecase(this._stockRepository);

  final StockRepository _stockRepository;

  @override
  Future<Result<List<StockMovementEntity>>> call(StockMovementsParams params) async =>
      _stockRepository.getStockMovements(product: params.product, movementType: params.movementType);
}

class StockAdjustmentParams {
  final int productId;
  final int quantity;
  final String? reason;

  const StockAdjustmentParams({
    required this.productId,
    required this.quantity,
    this.reason,
  });
}

class StockMovementsParams {
  final int? product;
  final String? movementType;

  const StockMovementsParams({this.product, this.movementType});
}

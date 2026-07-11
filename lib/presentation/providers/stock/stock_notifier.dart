import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../core/common/result.dart';
import '../../../domain/entities/stock_movement_entity.dart';
import '../../../domain/usecases/params/no_param.dart';
import '../../../domain/usecases/stock_usecases.dart';
import 'stock_state.dart';

final stockNotifierProvider = NotifierProvider<StockNotifier, StockState>(
  StockNotifier.new,
);

class StockNotifier extends Notifier<StockState> {
  @override
  StockState build() {
    return const StockState();
  }

  Future<void> loadOverview() async {
    state = state.copyWith(isLoading: true);
    final repository = ref.read(stockRepositoryProvider);
    final result = await GetStockOverviewUsecase(repository).call(NoParam());
    if (result.isSuccess) {
      state = state.copyWith(overview: result.data, isLoading: false);
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> loadMovements({int? product, String? movementType}) async {
    state = state.copyWith(isLoading: true);
    final repository = ref.read(stockRepositoryProvider);
    final result = await GetStockMovementsUsecase(repository).call(
      StockMovementsParams(product: product, movementType: movementType),
    );
    if (result.isSuccess) {
      state = state.copyWith(movements: result.data, isLoading: false);
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<Result<void>> adjustStock(int productId, int quantity, String? reason) async {
    final repository = ref.read(stockRepositoryProvider);
    final result = await CreateStockAdjustmentUsecase(repository).call(
      StockAdjustmentParams(productId: productId, quantity: quantity, reason: reason),
    );
    if (result.isSuccess) {
      await loadOverview();
      await loadMovements();
    }
    return result;
  }
}

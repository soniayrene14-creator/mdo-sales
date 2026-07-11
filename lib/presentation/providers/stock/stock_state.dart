import '../../../domain/entities/stock_movement_entity.dart';
import '../../../domain/entities/stock_overview_entity.dart';

class StockState {
  final StockOverviewEntity? overview;
  final List<StockMovementEntity>? movements;
  final bool isLoading;

  const StockState({
    this.overview,
    this.movements,
    this.isLoading = false,
  });

  StockState copyWith({
    StockOverviewEntity? overview,
    List<StockMovementEntity>? movements,
    bool? isLoading,
  }) {
    return StockState(
      overview: overview ?? this.overview,
      movements: movements ?? this.movements,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

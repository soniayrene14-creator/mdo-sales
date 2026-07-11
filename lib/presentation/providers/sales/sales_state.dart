import '../../../domain/entities/sale_entity.dart';

class SalesState {
  final List<SaleEntity>? sales;
  final SaleEntity? selectedSale;
  final bool isLoading;

  const SalesState({
    this.sales,
    this.selectedSale,
    this.isLoading = false,
  });

  SalesState copyWith({
    List<SaleEntity>? sales,
    SaleEntity? selectedSale,
    bool? isLoading,
  }) {
    return SalesState(
      sales: sales ?? this.sales,
      selectedSale: selectedSale ?? this.selectedSale,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

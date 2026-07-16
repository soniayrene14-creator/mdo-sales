import '../../../domain/entities/product_entity.dart';

class ProductsState {
  final List<ProductEntity>? allProducts;
  final List<ProductEntity>? lowStockProducts;
  final List<ProductEntity>? outOfStockProducts;
  final List<ProductEntity>? inactiveProducts;
  final bool isLoadingMore;
  final bool isLoadingTab;
  final String? error;

  const ProductsState({
    this.allProducts,
    this.lowStockProducts,
    this.outOfStockProducts,
    this.inactiveProducts,
    this.isLoadingMore = false,
    this.isLoadingTab = false,
    this.error,
  });

  ProductsState copyWith({
    List<ProductEntity>? allProducts,
    List<ProductEntity>? lowStockProducts,
    List<ProductEntity>? outOfStockProducts,
    List<ProductEntity>? inactiveProducts,
    bool? isLoadingMore,
    bool? isLoadingTab,
    String? error,
  }) {
    return ProductsState(
      allProducts: allProducts ?? this.allProducts,
      lowStockProducts: lowStockProducts ?? this.lowStockProducts,
      outOfStockProducts: outOfStockProducts ?? this.outOfStockProducts,
      inactiveProducts: inactiveProducts ?? this.inactiveProducts,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isLoadingTab: isLoadingTab ?? this.isLoadingTab,
      error: error ?? this.error,
    );
  }
}

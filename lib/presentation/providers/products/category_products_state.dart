import '../../../domain/entities/product_entity.dart';

class CategoryProductsState {
  final List<ProductEntity>? products;
  final bool isLoadingMore;

  const CategoryProductsState({
    this.products,
    this.isLoadingMore = false,
  });

  CategoryProductsState copyWith({
    List<ProductEntity>? products,
    bool? isLoadingMore,
  }) {
    return CategoryProductsState(
      products: products ?? this.products,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

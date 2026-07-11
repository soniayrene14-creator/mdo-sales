import '../../../domain/entities/category_entity.dart';

class CategoriesState {
  final List<CategoryEntity>? categories;
  final bool isLoading;

  const CategoriesState({
    this.categories,
    this.isLoading = false,
  });

  CategoriesState copyWith({
    List<CategoryEntity>? categories,
    bool? isLoading,
  }) {
    return CategoriesState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

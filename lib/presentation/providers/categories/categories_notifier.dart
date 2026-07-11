import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../core/common/result.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/usecases/category_usecases.dart';
import '../../../domain/usecases/params/no_param.dart';
import 'categories_state.dart';

final categoriesNotifierProvider = NotifierProvider<CategoriesNotifier, CategoriesState>(
  CategoriesNotifier.new,
);

class CategoriesNotifier extends Notifier<CategoriesState> {
  @override
  CategoriesState build() {
    return const CategoriesState();
  }

  Future<void> loadCategories() async {
    state = state.copyWith(isLoading: true);
    final repository = ref.read(categoryRepositoryProvider);
    final result = await GetAllCategoriesUsecase(repository).call(NoParam());
    if (result.isSuccess) {
      state = state.copyWith(categories: result.data, isLoading: false);
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<Result<CategoryEntity>> addCategory(String name, String? description) async {
    final repository = ref.read(categoryRepositoryProvider);
    final category = CategoryEntity(
      id: 0,
      name: name,
      description: description,
      productCount: 0,
    );
    final result = await CreateCategoryUsecase(repository).call(category);
    if (result.isSuccess) {
      await loadCategories();
    }
    return result;
  }

  Future<Result<void>> updateCategory(CategoryEntity category) async {
    final repository = ref.read(categoryRepositoryProvider);
    final result = await UpdateCategoryUsecase(repository).call(category);
    if (result.isSuccess) {
      await loadCategories();
    }
    return result;
  }

  Future<Result<void>> deleteCategory(int categoryId) async {
    final repository = ref.read(categoryRepositoryProvider);
    final result = await DeleteCategoryUsecase(repository).call(categoryId);
    if (result.isSuccess) {
      await loadCategories();
    }
    return result;
  }
}

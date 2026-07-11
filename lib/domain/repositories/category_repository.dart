import '../../../core/common/result.dart';
import '../entities/category_entity.dart';

abstract class CategoryRepository {
  Future<Result<List<CategoryEntity>>> getAllCategories();
  Future<Result<CategoryEntity>> createCategory(CategoryEntity category);
  Future<Result<CategoryEntity>> updateCategory(CategoryEntity category);
  Future<Result<void>> deleteCategory(int categoryId);
}

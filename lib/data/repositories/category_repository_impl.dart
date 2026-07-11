import '../../../core/common/result.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/repositories/category_repository.dart';
import '../models/category_model.dart';
import '../datasources/remote/product_django_remote_datasource_impl.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final ProductDjangoRemoteDataSourceImpl _remoteDataSource;

  CategoryRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<CategoryEntity>>> getAllCategories() async {
    final result = await _remoteDataSource.getAllCategories();
    if (result.isFailure) return Result.failure(error: result.error!);
    final categories = result.data!.map((e) => e.toEntity()).toList();
    return Result.success(data: categories);
  }

  @override
  Future<Result<CategoryEntity>> createCategory(CategoryEntity category) async {
    final model = CategoryModel.fromEntity(category);
    final result = await _remoteDataSource.createCategory(model);
    if (result.isFailure) return Result.failure(error: result.error!);
    return Result.success(data: result.data!.toEntity());
  }

  @override
  Future<Result<CategoryEntity>> updateCategory(CategoryEntity category) async {
    final model = CategoryModel.fromEntity(category);
    final result = await _remoteDataSource.updateCategory(model);
    if (result.isFailure) return Result.failure(error: result.error!);
    return Result.success(data: result.data!.toEntity());
  }

  @override
  Future<Result<void>> deleteCategory(int categoryId) async {
    final result = await _remoteDataSource.deleteCategory(categoryId);
    return result;
  }
}

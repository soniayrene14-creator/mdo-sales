import '../../core/common/result.dart';
import '../../core/usecase/usecase.dart';
import '../../domain/entities/category_entity.dart';
import '../repositories/category_repository.dart';
import 'params/no_param.dart';

class GetAllCategoriesUsecase extends Usecase<Result, NoParam> {
  GetAllCategoriesUsecase(this._categoryRepository);

  final CategoryRepository _categoryRepository;

  @override
  Future<Result<List<CategoryEntity>>> call(NoParam params) async => _categoryRepository.getAllCategories();
}

class CreateCategoryUsecase extends Usecase<Result, CategoryEntity> {
  CreateCategoryUsecase(this._categoryRepository);

  final CategoryRepository _categoryRepository;

  @override
  Future<Result<CategoryEntity>> call(CategoryEntity params) async => _categoryRepository.createCategory(params);
}

class UpdateCategoryUsecase extends Usecase<Result, CategoryEntity> {
  UpdateCategoryUsecase(this._categoryRepository);

  final CategoryRepository _categoryRepository;

  @override
  Future<Result<CategoryEntity>> call(CategoryEntity params) async => _categoryRepository.updateCategory(params);
}

class DeleteCategoryUsecase extends Usecase<Result, int> {
  DeleteCategoryUsecase(this._categoryRepository);

  final CategoryRepository _categoryRepository;

  @override
  Future<Result<void>> call(int params) async => _categoryRepository.deleteCategory(params);
}

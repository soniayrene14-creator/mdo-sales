import '../../core/common/result.dart';
import '../../core/usecase/usecase.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';
import 'params/base_params.dart';
import 'params/no_param.dart';

class SyncAllUserProductsUsecase extends Usecase<Result, String> {
  SyncAllUserProductsUsecase(this._productRepository);

  final ProductRepository _productRepository;

  @override
  Future<Result<int>> call(String params) async => _productRepository.syncAllUserProducts(params);
}

class GetUserProductsUsecase extends Usecase<Result, BaseParams> {
  GetUserProductsUsecase(this._productRepository);

  final ProductRepository _productRepository;

  @override
  Future<Result<List<ProductEntity>>> call(BaseParams params) async => _productRepository.getUserProducts(
    params.param,
    orderBy: params.orderBy,
    sortBy: params.sortBy,
    limit: params.limit,
    offset: params.offset,
    contains: params.contains,
    categoryId: params.categoryId,
  );
}

class GetProductUsecase extends Usecase<Result, int> {
  GetProductUsecase(this._productRepository);

  final ProductRepository _productRepository;

  @override
  Future<Result<ProductEntity?>> call(int params) async => _productRepository.getProduct(params);
}

class CreateProductUsecase extends Usecase<Result, ({ProductEntity product, String? imageFilePath})> {
  CreateProductUsecase(this._productRepository);

  final ProductRepository _productRepository;

  @override
  Future<Result<int>> call(({ProductEntity product, String? imageFilePath}) params) async =>
      _productRepository.createProduct(params.product, imageFilePath: params.imageFilePath);
}

class UpdateProductUsecase extends Usecase<Result<void>, ({ProductEntity product, String? imageFilePath})> {
  UpdateProductUsecase(this._productRepository);

  final ProductRepository _productRepository;

  @override
  Future<Result<void>> call(({ProductEntity product, String? imageFilePath}) params) async =>
      _productRepository.updateProduct(params.product, imageFilePath: params.imageFilePath);
}

class DeleteProductUsecase extends Usecase<Result<void>, int> {
  DeleteProductUsecase(this._productRepository);

  final ProductRepository _productRepository;

  @override
  Future<Result<void>> call(int params) async => _productRepository.deleteProduct(params);
}

class GetLowStockProductsUsecase extends Usecase<Result, NoParam> {
  GetLowStockProductsUsecase(this._productRepository);

  final ProductRepository _productRepository;

  @override
  Future<Result<List<ProductEntity>>> call(NoParam params) async => _productRepository.getLowStockProducts();
}

class GetOutOfStockProductsUsecase extends Usecase<Result, NoParam> {
  GetOutOfStockProductsUsecase(this._productRepository);

  final ProductRepository _productRepository;

  @override
  Future<Result<List<ProductEntity>>> call(NoParam params) async => _productRepository.getOutOfStockProducts();
}

class GetInactiveProductsUsecase extends Usecase<Result, NoParam> {
  GetInactiveProductsUsecase(this._productRepository);

  final ProductRepository _productRepository;

  @override
  Future<Result<List<ProductEntity>>> call(NoParam params) async => _productRepository.getInactiveProducts();
}

class ReactivateProductUsecase extends Usecase<Result, int> {
  ReactivateProductUsecase(this._productRepository);

  final ProductRepository _productRepository;

  @override
  Future<Result<ProductEntity>> call(int params) async => _productRepository.reactivateProduct(params);
}

import '../../core/common/result.dart';
import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<Result<int>> syncAllUserProducts(String userId);

  Future<Result<ProductEntity?>> getProduct(int productId);

  Future<Result<int>> createProduct(ProductEntity product, {String? imageFilePath});

  Future<Result<void>> updateProduct(ProductEntity product, {String? imageFilePath});

  Future<Result<void>> deleteProduct(int productId);

  Future<Result<List<ProductEntity>>> getUserProducts(
    String userId, {
    String orderBy,
    String sortBy,
    int limit,
    int? offset,
    String? contains,
  });

  Future<Result<List<ProductEntity>>> getLowStockProducts();

  Future<Result<List<ProductEntity>>> getOutOfStockProducts();

  Future<Result<List<ProductEntity>>> getInactiveProducts();

  Future<Result<ProductEntity>> reactivateProduct(int productId);
}

import '../../../core/common/result.dart';
import '../../models/product_model.dart';

abstract class ProductDatasource {
  Future<Result<int>> createProduct(ProductModel product, {String? imageFilePath});

  Future<Result<void>> updateProduct(ProductModel product, {String? imageFilePath});

  Future<Result<void>> deleteProduct(int id);

  Future<Result<ProductModel?>> getProduct(int id);

  Future<Result<List<ProductModel>>> getAllUserProducts(String userId);

  Future<Result<List<ProductModel>>> getUserProducts(
    String userId, {
    String orderBy,
    String sortBy,
    int limit,
    int? offset,
    String? contains,
  });

  Future<Result<List<ProductModel>>> getLowStockProducts();

  Future<Result<List<ProductModel>>> getOutOfStockProducts();

  Future<Result<List<ProductModel>>> getInactiveProducts();

  Future<Result<ProductModel>> reactivateProduct(int id);
}

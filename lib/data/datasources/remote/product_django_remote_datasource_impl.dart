import '../../../core/common/result.dart';
import '../../../core/services/api/api_client.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../models/stock_movement_model.dart';
import '../../models/stock_overview_model.dart';
import '../interfaces/product_datasource.dart';

class ProductDjangoRemoteDataSourceImpl implements ProductDatasource {
  final ApiClient apiClient;

  ProductDjangoRemoteDataSourceImpl({required this.apiClient});

  List<ProductModel> _parseList(dynamic json) {
    final results = json?['results'];
    if (results is List) {
      return results.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return <ProductModel>[];
  }

  /// Parses actions that return a bare JSON array (no pagination wrapper),
  /// e.g. `low-stock`, `out-of-stock`.
  List<ProductModel> _parseRawList(dynamic json) {
    if (json is List) {
      return json.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return <ProductModel>[];
  }

  /// Fields matching ProductSerializer's writable fields, as a multipart form
  /// (Django's ImageField only accepts an actual uploaded file, not a JSON
  /// string). `reference`, `is_active`, `created_at` and `updated_at` are
  /// server-managed (read-only), and `low_stock_threshold` is only included
  /// when set, since the model field isn't nullable (only defaulted).
  Map<String, String> _buildWriteFields(ProductModel product) {
    final fields = <String, String>{
      'name': product.name,
      'category': '${product.categoryId}',
      'description': product.description ?? '',
      'price': '${product.price}',
      'quantity': '${product.stock}',
    };

    if (product.lowStockThreshold != null) {
      fields['low_stock_threshold'] = '${product.lowStockThreshold}';
    }

    return fields;
  }

  @override
  Future<Result<int>> createProduct(ProductModel product, {String? imageFilePath}) async {
    try {
      final result = await apiClient.postMultipart<Map<String, dynamic>>(
        '/api/v1/products/',
        fields: _buildWriteFields(product),
        filePath: imageFilePath,
        parser: (json) => json ?? <String, dynamic>{},
      );

      if (result.isFailure) {
        return Result.failure(error: result.error!);
      }

      return Result.success(data: result.data!['id'] as int);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> updateProduct(ProductModel product, {String? imageFilePath}) async {
    try {
      final result = await apiClient.putMultipart<Map<String, dynamic>>(
        '/api/v1/products/${product.id}/',
        fields: _buildWriteFields(product),
        filePath: imageFilePath,
        parser: (json) => json ?? <String, dynamic>{},
      );

      if (result.isFailure) {
        return Result.failure(error: result.error!);
      }

      return Result<void>.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> deleteProduct(int id) async {
    try {
      final result = await apiClient.delete<Map<String, dynamic>>(
        '/api/v1/products/$id/',
        parser: (json) => json ?? <String, dynamic>{},
      );

      if (result.isFailure) {
        return Result.failure(error: result.error!);
      }

      return Result<void>.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<ProductModel?>> getProduct(int id) async {
    try {
      final result = await apiClient.get<Map<String, dynamic>>(
        '/api/v1/products/$id/',
        parser: (json) => json ?? <String, dynamic>{},
      );

      if (result.isFailure) {
        return Result.failure(error: result.error!);
      }

      final data = result.data!;
      if (data.isEmpty) {
        return Result.success(data: null);
      }

      return Result.success(data: ProductModel.fromJson(data));
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<ProductModel>>> getAllUserProducts(String userId) async {
    try {
      final result = await apiClient.get<List<ProductModel>>(
        '/api/v1/products/',
        parser: _parseList,
      );

      if (result.isFailure) {
        return Result.failure(error: result.error!);
      }

      return Result.success(data: result.data ?? <ProductModel>[]);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<ProductModel>>> getUserProducts(
    String userId, {
    String orderBy = '',
    String sortBy = '',
    int limit = 20,
    int? offset,
    String? contains,
  }) async {
    try {
      final query = <String, dynamic>{'is_active': 'true'};
      if (contains != null && contains.isNotEmpty) {
        query['search'] = contains;
      }
      if (sortBy.isNotEmpty) {
        query['ordering'] = sortBy;
      } else if (orderBy.isNotEmpty) {
        query['ordering'] = orderBy;
      }
      if (limit > 0) {
        query['page'] = (offset != null && offset > 0 ? (offset ~/ limit) + 1 : 1).toString();
      }

      final result = await apiClient.get<List<ProductModel>>(
        '/api/v1/products/',
        query: query,
        parser: _parseList,
      );

      if (result.isFailure) {
        return Result.failure(error: result.error!);
      }

      return Result.success(data: result.data ?? <ProductModel>[]);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<ProductModel>>> getLowStockProducts() async {
    try {
      final result = await apiClient.get<List<ProductModel>>(
        '/api/v1/products/low-stock/',
        parser: _parseRawList,
      );

      if (result.isFailure) {
        return Result.failure(error: result.error!);
      }

      return Result.success(data: result.data ?? <ProductModel>[]);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<ProductModel>>> getOutOfStockProducts() async {
    try {
      final result = await apiClient.get<List<ProductModel>>(
        '/api/v1/products/out-of-stock/',
        parser: _parseRawList,
      );

      if (result.isFailure) {
        return Result.failure(error: result.error!);
      }

      return Result.success(data: result.data ?? <ProductModel>[]);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<ProductModel>>> getInactiveProducts() async {
    try {
      final result = await apiClient.get<List<ProductModel>>(
        '/api/v1/products/',
        query: {'is_active': 'false'},
        parser: _parseList,
      );

      if (result.isFailure) {
        return Result.failure(error: result.error!);
      }

      return Result.success(data: result.data ?? <ProductModel>[]);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<ProductModel>> reactivateProduct(int id) async {
    try {
      final result = await apiClient.post<Map<String, dynamic>>(
        '/api/v1/products/$id/reactivate/',
        null,
        parser: (json) => json as Map<String, dynamic>? ?? <String, dynamic>{},
      );

      if (result.isFailure) {
        return Result.failure(error: result.error!);
      }

      return Result.success(data: ProductModel.fromJson(result.data!));
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  Future<Result<List<CategoryModel>>> getAllCategories() async {
    try {
      final result = await apiClient.get<List<CategoryModel>>(
        '/api/v1/categories/',
        parser: _parseCategoryList,
      );

      if (result.isFailure) {
        return Result.failure(error: result.error!);
      }

      return Result.success(data: result.data ?? <CategoryModel>[]);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  Future<Result<CategoryModel>> createCategory(CategoryModel category) async {
    try {
      final result = await apiClient.post<Map<String, dynamic>>(
        '/api/v1/categories/',
        category.toJson(),
        parser: (json) => json ?? <String, dynamic>{},
      );

      if (result.isFailure) {
        return Result.failure(error: result.error!);
      }

      return Result.success(data: CategoryModel.fromJson(result.data!));
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  Future<Result<CategoryModel>> updateCategory(CategoryModel category) async {
    try {
      final result = await apiClient.put<Map<String, dynamic>>(
        '/api/v1/categories/${category.id}/',
        category.toJson(),
        parser: (json) => json ?? <String, dynamic>{},
      );

      if (result.isFailure) {
        return Result.failure(error: result.error!);
      }

      return Result.success(data: CategoryModel.fromJson(result.data!));
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  Future<Result<void>> deleteCategory(int categoryId) async {
    try {
      final result = await apiClient.delete<Map<String, dynamic>>(
        '/api/v1/categories/$categoryId/',
        parser: (json) => json ?? <String, dynamic>{},
      );

      if (result.isFailure) {
        return Result.failure(error: result.error!);
      }

      return Result<void>.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  Future<Result<StockOverviewModel>> getStockOverview() async {
    try {
      final result = await apiClient.get<Map<String, dynamic>>(
        '/api/v1/stock/',
        parser: (json) => json ?? <String, dynamic>{},
      );

      if (result.isFailure) {
        return Result.failure(error: result.error!);
      }

      return Result.success(data: StockOverviewModel.fromJson(result.data!));
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  Future<Result<StockMovementModel>> createStockAdjustment(int productId, int quantity, String? reason) async {
    try {
      final result = await apiClient.post<Map<String, dynamic>>(
        '/api/v1/stock/adjustments/',
        {
          'product': productId,
          'quantity': quantity,
          'reason': reason,
        },
        parser: (json) => json ?? <String, dynamic>{},
      );

      if (result.isFailure) {
        return Result.failure(error: result.error!);
      }

      return Result.success(data: StockMovementModel.fromJson(result.data!));
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  Future<Result<List<StockMovementModel>>> getStockMovements({int? product, String? movementType}) async {
    try {
      final query = <String, dynamic>{};
      if (product != null) query['product'] = product.toString();
      if (movementType != null && movementType.isNotEmpty) query['movement_type'] = movementType;

      final result = await apiClient.get<List<StockMovementModel>>(
        '/api/v1/stock/movements/',
        query: query,
        parser: _parseStockMovementList,
      );

      if (result.isFailure) {
        return Result.failure(error: result.error!);
      }

      return Result.success(data: result.data ?? <StockMovementModel>[]);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  List<CategoryModel> _parseCategoryList(dynamic json) {
    final results = json?['results'];
    if (results is List) {
      return results.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return <CategoryModel>[];
  }

  List<StockMovementModel> _parseStockMovementList(dynamic json) {
    final results = json?['results'];
    if (results is List) {
      return results.map((e) => StockMovementModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return <StockMovementModel>[];
  }
}

import 'package:sqflite/sqflite.dart';

import '../../../core/common/result.dart';
import '../../../core/services/database/database_config.dart';
import '../../../core/services/database/database_service.dart';
import '../../models/product_model.dart';
import '../interfaces/product_datasource.dart';

class ProductLocalDatasourceImpl extends ProductDatasource {
  final DatabaseService _databaseService;

  ProductLocalDatasourceImpl(this._databaseService);

  @override
  Future<Result<int>> createProduct(ProductModel product, {String? imageFilePath}) async {
    try {
      // Cache the local file path so the offline UI has something to show
      // before this product syncs and gets a real server image URL.
      if (imageFilePath != null) product.imageUrl = imageFilePath;

      await _databaseService.database.insert(
        DatabaseConfig.productTableName,
        product.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // The id has been generated in models
      return Result.success(data: product.id);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> updateProduct(ProductModel product, {String? imageFilePath}) async {
    try {
      if (imageFilePath != null) product.imageUrl = imageFilePath;

      await _databaseService.database.update(
        DatabaseConfig.productTableName,
        product.toJson(),
        where: 'id = ?',
        whereArgs: [product.id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> deleteProduct(int id) async {
    try {
      // Soft delete, matching the backend (a sold product can't be hard
      // deleted due to a protected FK). Hard-deleting locally while the
      // remote row survives made the sync logic see it as "remote-only" and
      // resurrect it as a fresh local row on the next sync.
      await _databaseService.database.update(
        DatabaseConfig.productTableName,
        {'is_active': 0},
        where: 'id = ?',
        whereArgs: [id],
      );

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<ProductModel?>> getProduct(int id) async {
    try {
      var res = await _databaseService.database.query(
        DatabaseConfig.productTableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (res.isEmpty) return Result.success(data: null);

      return Result.success(data: ProductModel.fromJson(res.first));
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<ProductModel>>> getAllUserProducts(String userId) async {
    try {
      var res = await _databaseService.database.query(
        DatabaseConfig.productTableName,
        where: 'createdById = ?',
        whereArgs: [userId],
      );

      return Result.success(
        data: res.map((e) => ProductModel.fromJson(e)).toList(),
      );
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<ProductModel>>> getUserProducts(
    String userId, {
    String orderBy = 'createdAt',
    String sortBy = 'DESC',
    int limit = 10,
    int? offset,
    String? contains,
    int? categoryId,
  }) async {
    try {
      final whereClauses = ['createdById = ?', 'name LIKE ?', 'is_active = 1'];
      final whereArgs = <Object?>[userId, "%${contains ?? ''}%"];

      if (categoryId != null) {
        whereClauses.add('category = ?');
        whereArgs.add(categoryId);
      }

      var res = await _databaseService.database.query(
        DatabaseConfig.productTableName,
        where: whereClauses.join(' AND '),
        whereArgs: whereArgs,
        orderBy: '$orderBy $sortBy',
        limit: limit,
        offset: offset,
      );

      return Result.success(
        data: res.map((e) => ProductModel.fromJson(e)).toList(),
      );
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<ProductModel>>> getLowStockProducts() async {
    try {
      final res = await _databaseService.database.query(
        DatabaseConfig.productTableName,
        where: 'stock_status = ?',
        whereArgs: ['faible'],
      );

      return Result.success(data: res.map((e) => ProductModel.fromJson(e)).toList());
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<ProductModel>>> getOutOfStockProducts() async {
    try {
      final res = await _databaseService.database.query(
        DatabaseConfig.productTableName,
        where: 'stock_status = ?',
        whereArgs: ['rupture'],
      );

      return Result.success(data: res.map((e) => ProductModel.fromJson(e)).toList());
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<ProductModel>>> getInactiveProducts() async {
    try {
      final res = await _databaseService.database.query(
        DatabaseConfig.productTableName,
        where: 'is_active = ?',
        whereArgs: [0],
      );

      return Result.success(data: res.map((e) => ProductModel.fromJson(e)).toList());
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  /// Reassigns a locally-cached product's id once the server has assigned
  /// its real id, so future syncs recognize it instead of re-creating it.
  Future<Result<void>> reassignId(int oldId, int newId) async {
    try {
      if (oldId == newId) return Result.success(data: null);

      await _databaseService.database.update(
        DatabaseConfig.productTableName,
        {'id': newId},
        where: 'id = ?',
        whereArgs: [oldId],
      );

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<ProductModel>> reactivateProduct(int id) async {
    try {
      await _databaseService.database.update(
        DatabaseConfig.productTableName,
        {'is_active': 1},
        where: 'id = ?',
        whereArgs: [id],
      );

      final res = await getProduct(id);
      if (res.isFailure) return Result.failure(error: res.error!);
      if (res.data == null) return Result.failure(error: 'Product $id not found locally.');

      return Result.success(data: res.data!);
    } catch (e) {
      return Result.failure(error: e);
    }
  }
}

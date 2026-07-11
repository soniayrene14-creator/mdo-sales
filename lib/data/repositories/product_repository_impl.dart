import 'dart:convert';

import '../../core/common/result.dart';
import '../../core/constants/constants.dart';
import '../../core/services/connectivity/ping_service.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/local/product_local_datasource_impl.dart';
import '../datasources/local/queued_action_local_datasource_impl.dart';
import '../datasources/remote/product_django_remote_datasource_impl.dart';
import '../models/product_model.dart';
import '../models/queued_action_model.dart';

class ProductRepositoryImpl extends ProductRepository {
  final PingService pingService;
  final ProductLocalDatasourceImpl productLocalDatasource;
  final ProductDjangoRemoteDataSourceImpl productRemoteDatasource;
  final QueuedActionLocalDatasourceImpl queuedActionLocalDatasource;

  ProductRepositoryImpl({
    required this.pingService,
    required this.productLocalDatasource,
    required this.productRemoteDatasource,
    required this.queuedActionLocalDatasource,
  });

  @override
  Future<Result<int>> syncAllUserProducts(String userId) async {
    try {
      if (pingService.isConnected) {
        final local = await productLocalDatasource.getAllUserProducts(userId);
        if (local.isFailure) return Result.failure(error: local.error!);

        final remote = await productRemoteDatasource.getAllUserProducts(userId);
        if (remote.isFailure) return Result.failure(error: remote.error!);

        final res = await _syncProducts(local.data!, remote.data!);

        // Sum all local and remote sync counts
        int totalSyncedCount = res.$1 + res.$2;

        // Return synced data count
        return Result.success(data: totalSyncedCount);
      }

      return Result.success(data: 0);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<ProductEntity>>> getUserProducts(
    String userId, {
    String orderBy = 'createdAt',
    String sortBy = 'DESC',
    int limit = 10,
    int? offset,
    String? contains,
  }) async {
    try {
      // Reconciliation (creating missing records on either side) only ever
      // happens in the full, unpaginated syncAllUserProducts(). Running it
      // here on page-sliced windows compared local vs. remote subsets that
      // don't line up once the two sides drift in size or ordering, which
      // kept recreating "unmatched" records and duplicating products.
      if (pingService.isConnected) {
        final remote = await productRemoteDatasource.getUserProducts(
          userId,
          orderBy: orderBy,
          sortBy: sortBy,
          limit: limit,
          offset: offset,
          contains: contains,
        );

        if (remote.isFailure) return Result.failure(error: remote.error!);

        return Result.success(data: remote.data!.map((e) => e.toEntity()).toList());
      }

      final local = await productLocalDatasource.getUserProducts(
        userId,
        orderBy: orderBy,
        sortBy: sortBy,
        limit: limit,
        offset: offset,
        contains: contains,
      );

      if (local.isFailure) return Result.failure(error: local.error!);

      return Result.success(data: local.data!.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<ProductEntity>>> getLowStockProducts() async {
    final result = await productRemoteDatasource.getLowStockProducts();
    if (result.isFailure) return Result.failure(error: result.error!);
    return Result.success(data: result.data!.map((e) => e.toEntity()).toList());
  }

  @override
  Future<Result<List<ProductEntity>>> getOutOfStockProducts() async {
    final result = await productRemoteDatasource.getOutOfStockProducts();
    if (result.isFailure) return Result.failure(error: result.error!);
    return Result.success(data: result.data!.map((e) => e.toEntity()).toList());
  }

  @override
  Future<Result<List<ProductEntity>>> getInactiveProducts() async {
    final result = await productRemoteDatasource.getInactiveProducts();
    if (result.isFailure) return Result.failure(error: result.error!);
    return Result.success(data: result.data!.map((e) => e.toEntity()).toList());
  }

  @override
  Future<Result<ProductEntity>> reactivateProduct(int productId) async {
    final result = await productRemoteDatasource.reactivateProduct(productId);
    if (result.isFailure) return Result.failure(error: result.error!);
    return Result.success(data: result.data!.toEntity());
  }

  @override
  Future<Result<ProductEntity?>> getProduct(int productId) async {
    try {
      // Same reasoning as getUserProducts(): reconciliation must not run
      // from a read path, or a locally-deleted product gets recreated the
      // moment its detail page (or a list containing it) is reloaded.
      if (pingService.isConnected) {
        final remote = await productRemoteDatasource.getProduct(productId);
        if (remote.isFailure) return Result.failure(error: remote.error!);

        return Result.success(data: remote.data?.toEntity());
      }

      final local = await productLocalDatasource.getProduct(productId);
      if (local.isFailure) return Result.failure(error: local.error!);

      return Result.success(data: local.data?.toEntity());
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<int>> createProduct(ProductEntity product, {String? imageFilePath}) async {
    try {
      final data = ProductModel.fromEntity(product);
      final localId = data.id;

      final local = await productLocalDatasource.createProduct(data, imageFilePath: imageFilePath);
      if (local.isFailure) return Result.failure(error: local.error!);

      if (pingService.isConnected) {
        final remote = await productRemoteDatasource.createProduct(data, imageFilePath: imageFilePath);
        if (remote.isFailure) return Result.failure(error: remote.error!);

        // The server assigns the real id; without reconciling it here, every
        // future sync would see this local record as "unmatched" and
        // re-create it remotely on every sync (endless duplication).
        final remoteId = remote.data!;
        await productLocalDatasource.reassignId(localId, remoteId);

        return Result.success(data: remoteId);
      } else {
        final res = await queuedActionLocalDatasource.createQueuedAction(
          QueuedActionModel(
            id: DateTime.now().millisecond,
            repository: 'ProductRepositoryImpl',
            method: 'createProduct',
            param: jsonEncode({...data.toJson(), 'imageFilePath': imageFilePath}),
            isCritical: true,
            createdAt: DateTime.now().toIso8601String(),
          ),
        );

        if (res.isFailure) return Result.failure(error: res.error!);
      }

      return Result.success(data: local.data!);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> deleteProduct(int productId) async {
    try {
      final local = await productLocalDatasource.deleteProduct(productId);
      if (local.isFailure) return Result.failure(error: local.error!);

      if (pingService.isConnected) {
        final remote = await productRemoteDatasource.deleteProduct(productId);
        if (remote.isFailure) return Result.failure(error: remote.error!);
      } else {
        final res = await queuedActionLocalDatasource.createQueuedAction(
          QueuedActionModel(
            id: DateTime.now().millisecond,
            repository: 'ProductRepositoryImpl',
            method: 'deleteProduct',
            param: productId.toString(),
            isCritical: true,
            createdAt: DateTime.now().toIso8601String(),
          ),
        );

        if (res.isFailure) return Result.failure(error: res.error!);
      }

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> updateProduct(ProductEntity product, {String? imageFilePath}) async {
    try {
      final data = ProductModel.fromEntity(product);

      final local = await productLocalDatasource.updateProduct(data, imageFilePath: imageFilePath);
      if (local.isFailure) return Result.failure(error: local.error!);

      if (pingService.isConnected) {
        final remote = await productRemoteDatasource.updateProduct(data, imageFilePath: imageFilePath);
        if (remote.isFailure) return Result.failure(error: remote.error!);
      } else {
        final res = await queuedActionLocalDatasource.createQueuedAction(
          QueuedActionModel(
            id: DateTime.now().millisecond,
            repository: 'ProductRepositoryImpl',
            method: 'updateProduct',
            param: jsonEncode({...data.toJson(), 'imageFilePath': imageFilePath}),
            isCritical: true,
            createdAt: DateTime.now().toIso8601String(),
          ),
        );

        if (res.isFailure) return Result.failure(error: res.error!);
      }

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  // Perform a sync between local and remote data
  Future<(int, int)> _syncProducts(List<ProductModel> local, List<ProductModel> remote) async {
    int syncedToLocalCount = 0;
    int syncedToRemoteCount = 0;

    // Track processed IDs to avoid duplicate syncing
    final processedIds = <int>{};

    // Process local products first
    for (final localData in local) {
      final matchRemoteData = remote.where((remoteData) => remoteData.id == localData.id).firstOrNull;

      if (matchRemoteData != null) {
        // Mark as processed
        processedIds.add(localData.id);

        final updatedAtLocal = DateTime.tryParse(localData.updatedAt ?? '');
        final updatedAtRemote = DateTime.tryParse(matchRemoteData.updatedAt ?? '');

        // Skip if either timestamp is invalid
        if (updatedAtLocal == null || updatedAtRemote == null) continue;

        final differenceInMinutes = updatedAtRemote.difference(updatedAtLocal).inMinutes;
        final isDiffSignificant = differenceInMinutes.abs() > Constants.minSyncIntervalToleranceForCriticalInMinutes;

        // Check which is newer based on the difference
        final isRemoteNewer = isDiffSignificant && differenceInMinutes > 0;
        final isLocalNewer = isDiffSignificant && differenceInMinutes < 0;

        if (isRemoteNewer) {
          // Save remote data to local db
          final res = await productLocalDatasource.updateProduct(matchRemoteData);
          if (res.isSuccess) syncedToLocalCount += 1;
        } else if (isLocalNewer) {
          // Update remote with local data
          final res = await productRemoteDatasource.updateProduct(localData);
          if (res.isSuccess) syncedToRemoteCount += 1;
        }
        // If not significant difference, do nothing (already in sync)
      } else {
        // No matching remote product, create it
        processedIds.add(localData.id);
        final res = await productRemoteDatasource.createProduct(localData);
        if (res.isSuccess) {
          syncedToRemoteCount += 1;
          // Reconcile the local id with the server-assigned one, otherwise
          // this product looks "unmatched" again on the next sync and gets
          // re-created endlessly.
          await productLocalDatasource.reassignId(localData.id, res.data!);
        }
      }
    }

    // Process remaining remote products that weren't in local
    for (final remoteData in remote) {
      // Skip if already processed in the first loop
      if (processedIds.contains(remoteData.id)) continue;

      // No matching local product, create it locally
      final res = await productLocalDatasource.createProduct(remoteData);
      if (res.isSuccess) syncedToLocalCount += 1;
    }

    return (syncedToLocalCount, syncedToRemoteCount);
  }
}

import 'dart:convert';

import '../../core/common/result.dart';
import '../../core/constants/constants.dart';
import '../../core/services/connectivity/ping_service.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/local/queued_action_local_datasource_impl.dart';
import '../datasources/local/transaction_local_datasource_impl.dart';
import '../datasources/remote/transaction_django_remote_datasource_impl.dart';
import '../models/queued_action_model.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl extends TransactionRepository {
  final PingService pingService;
  final TransactionLocalDatasourceImpl transactionLocalDatasource;
  final TransactionDjangoRemoteDataSourceImpl transactionRemoteDatasource;
  final QueuedActionLocalDatasourceImpl queuedActionLocalDatasource;

  TransactionRepositoryImpl({
    required this.pingService,
    required this.transactionLocalDatasource,
    required this.transactionRemoteDatasource,
    required this.queuedActionLocalDatasource,
  });

  @override
  Future<Result<int>> syncAllUserTransactions(String userId) async {
    try {
      if (pingService.isConnected) {
        var local = await transactionLocalDatasource.getAllUserTransactions(userId);
        if (local.isFailure) return Result.failure(error: local.error!);

        var remote = await transactionRemoteDatasource.getAllUserTransactions(userId);
        if (remote.isFailure) return Result.failure(error: remote.error!);

        var res = await syncTransactions(local.data!, remote.data!);

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
  Future<Result<List<TransactionEntity>>> getUserTransactions(
    String userId, {
    String orderBy = 'createdAt',
    String sortBy = 'DESC',
    int limit = 10,
    int? offset,
    String? contains,
  }) async {
    try {
      // Reconciliation (creating missing records on either side) only ever
      // happens in the full, unpaginated syncAllUserTransactions(). Running
      // it here on page-sliced windows compared local vs. remote subsets
      // that don't line up once the two sides drift in size or ordering,
      // which kept recreating "unmatched" records and duplicating
      // transactions.
      if (pingService.isConnected) {
        var remote = await transactionRemoteDatasource.getUserTransactions(
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

      var local = await transactionLocalDatasource.getUserTransactions(
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
  Future<Result<TransactionEntity?>> getTransaction(int transactionId) async {
    try {
      // Same reasoning as getUserTransactions(): reconciliation must not run
      // from a read path, or a locally-deleted transaction gets recreated
      // the moment its detail page (or a list containing it) is reloaded.
      if (pingService.isConnected) {
        var remote = await transactionRemoteDatasource.getTransaction(transactionId);
        if (remote.isFailure) return Result.failure(error: remote.error!);

        return Result.success(data: remote.data?.toEntity());
      }

      var local = await transactionLocalDatasource.getTransaction(transactionId);
      if (local.isFailure) return Result.failure(error: local.error!);

      return Result.success(data: local.data?.toEntity());
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<int>> createTransaction(TransactionEntity transaction) async {
    try {
      var data = TransactionModel.fromEntity(transaction);
      final localId = data.id;

      var local = await transactionLocalDatasource.createTransaction(data);
      if (local.isFailure) return Result.failure(error: local.error!);

      if (pingService.isConnected) {
        final remote = await transactionRemoteDatasource.createTransaction(data);
        if (remote.isFailure) return Result.failure(error: remote.error!);

        // The server assigns the real id; without reconciling it here, every
        // future sync would see this local record as "unmatched" and
        // re-create it remotely on every sync (endless duplication).
        final remoteId = remote.data!;
        await transactionLocalDatasource.reassignId(localId, remoteId);

        return Result.success(data: remoteId);
      } else {
        final res = await queuedActionLocalDatasource.createQueuedAction(
          QueuedActionModel(
            id: DateTime.now().millisecondsSinceEpoch,
            repository: 'TransactionRepositoryImpl',
            method: 'createTransaction',
            param: jsonEncode((data).toJson()),
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
  Future<Result<void>> deleteTransaction(int transactionId) async {
    try {
      final local = await transactionLocalDatasource.deleteTransaction(transactionId);
      if (local.isFailure) return Result.failure(error: local.error!);

      if (pingService.isConnected) {
        final remote = await transactionRemoteDatasource.deleteTransaction(transactionId);
        if (remote.isFailure) return Result.failure(error: remote.error!);
      } else {
        final res = await queuedActionLocalDatasource.createQueuedAction(
          QueuedActionModel(
            id: DateTime.now().millisecondsSinceEpoch,
            repository: 'TransactionRepositoryImpl',
            method: 'deleteTransaction',
            param: transactionId.toString(),
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
  Future<Result<void>> updateTransaction(TransactionEntity transaction) async {
    try {
      var data = TransactionModel.fromEntity(transaction);

      final local = await transactionLocalDatasource.updateTransaction(data);
      if (local.isFailure) return Result.failure(error: local.error!);

      if (pingService.isConnected) {
        final remote = await transactionRemoteDatasource.updateTransaction(data);
        if (remote.isFailure) return Result.failure(error: remote.error!);
      } else {
        final res = await queuedActionLocalDatasource.createQueuedAction(
          QueuedActionModel(
            id: DateTime.now().millisecondsSinceEpoch,
            repository: 'TransactionRepositoryImpl',
            method: 'updateTransaction',
            param: jsonEncode(data.toJson()),
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
  Future<(int, int)> syncTransactions(List<TransactionModel> local, List<TransactionModel> remote) async {
    int syncedToLocalCount = 0;
    int syncedToRemoteCount = 0;

    // Track processed IDs to avoid duplicate syncing
    final processedIds = <int>{};

    // Process local transactions first
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
          final res = await transactionLocalDatasource.updateTransaction(matchRemoteData);
          if (res.isSuccess) syncedToLocalCount += 1;
        } else if (isLocalNewer) {
          // Update remote with local data
          final res = await transactionRemoteDatasource.updateTransaction(localData);
          if (res.isSuccess) syncedToRemoteCount += 1;
        }
        // If not significant difference, do nothing (already in sync)
      } else {
        // No matching remote transaction, create it
        processedIds.add(localData.id);
        final res = await transactionRemoteDatasource.createTransaction(localData);
        if (res.isSuccess) {
          syncedToRemoteCount += 1;
          // Reconcile the local id with the server-assigned one, otherwise
          // this transaction looks "unmatched" again on the next sync and
          // gets re-created endlessly.
          await transactionLocalDatasource.reassignId(localData.id, res.data!);
        }
      }
    }

    // Process remaining remote transactions that weren't in local
    for (final remoteData in remote) {
      // Skip if already processed in the first loop
      if (processedIds.contains(remoteData.id)) continue;

      // No matching local transaction, create it locally
      final res = await transactionLocalDatasource.createTransaction(remoteData);
      if (res.isSuccess) syncedToLocalCount += 1;
    }

    return (syncedToLocalCount, syncedToRemoteCount);
  }
}

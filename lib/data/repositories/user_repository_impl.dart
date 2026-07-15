import 'dart:convert';

import '../../core/common/result.dart';
import '../../core/services/connectivity/ping_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/local/queued_action_local_datasource_impl.dart';
import '../datasources/local/user_local_datasource_impl.dart';
import '../datasources/remote/user_django_remote_datasource_impl.dart';
import '../models/queued_action_model.dart';
import '../models/user_model.dart';

class UserRepositoryImpl extends UserRepository {
  final PingService pingService;
  final UserLocalDatasourceImpl userLocalDatasource;
  final UserDjangoRemoteDataSourceImpl userRemoteDatasource;
  final QueuedActionLocalDatasourceImpl queuedActionLocalDatasource;

  UserRepositoryImpl({
    required this.pingService,
    required this.userLocalDatasource,
    required this.userRemoteDatasource,
    required this.queuedActionLocalDatasource,
  });

  @override
  Future<Result<UserEntity?>> getUser(String userId) async {
    try {
      var local = await userLocalDatasource.getUser(userId);
      if (local.isFailure) return Result.failure(error: local.error!);

      if (pingService.isConnected) {
        var remote = await userRemoteDatasource.getUser(userId);
        if (remote.isFailure) return Result.failure(error: remote.error!);

        // The server is always authoritative here: fields like role,
        // username and isActive aren't tracked in the local cache (it only
        // mirrors the profile fields editable offline), so preferring
        // "whichever is newer" could silently return a local copy stripped
        // of those fields.
        if (remote.data != null) await userLocalDatasource.updateUser(remote.data!);

        return Result.success(data: remote.data?.toEntity());
      }

      return Result.success(data: local.data?.toEntity());
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<UserEntity?>> getMe() async {
    try {
      if (pingService.isConnected) {
        final remote = await userRemoteDatasource.getMe();
        if (remote.isFailure) return Result.failure(error: remote.error!);

        if (remote.data != null) await userLocalDatasource.updateUser(remote.data!);

        return Result.success(data: remote.data?.toEntity());
      }

      final local = await userLocalDatasource.getMe();
      return Result.success(data: local.data?.toEntity());
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> updateMe(UserEntity user, {String? imageFilePath}) async {
    try {
      final local = await userLocalDatasource.updateUser(UserModel.fromEntity(user), imageFilePath: imageFilePath);
      if (local.isFailure) return Result.failure(error: local.error!);

      if (pingService.isConnected) {
        final remote = await userRemoteDatasource.updateMe(
          UserModel.fromEntity(user),
          imageFilePath: imageFilePath,
        );
        if (remote.isFailure) return Result.failure(error: remote.error!);
      } else {
        final res = await queuedActionLocalDatasource.createQueuedAction(
          QueuedActionModel(
            id: DateTime.now().millisecondsSinceEpoch,
            repository: 'UserRepositoryImpl',
            method: 'updateMe',
            param: jsonEncode({...UserModel.fromEntity(user).toJson(), 'imageFilePath': imageFilePath}),
            isCritical: false,
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
  Future<Result<String>> createUser(UserEntity user, {String? imageFilePath}) async {
    try {
      var local = await userLocalDatasource.createUser(UserModel.fromEntity(user), imageFilePath: imageFilePath);
      if (local.isFailure) return Result.failure(error: local.error!);

      if (pingService.isConnected) {
        final remote = await userRemoteDatasource.createUser(
          UserModel.fromEntity(user)..id = local.data!,
          imageFilePath: imageFilePath,
        );
        if (remote.isFailure) return Result.failure(error: remote.error!);
      } else {
        final res = await queuedActionLocalDatasource.createQueuedAction(
          QueuedActionModel(
            id: DateTime.now().millisecondsSinceEpoch,
            repository: 'UserRepositoryImpl',
            method: 'createUser',
            param: jsonEncode({
              ...(UserModel.fromEntity(user)..id = local.data!).toJson(),
              'imageFilePath': imageFilePath,
            }),
            isCritical: false,
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
  Future<Result<void>> deleteUser(String userId) async {
    try {
      final local = await userLocalDatasource.deleteUser(userId);
      if (local.isFailure) return Result.failure(error: local.error!);

      if (pingService.isConnected) {
        final remote = await userRemoteDatasource.deleteUser(userId);
        if (remote.isFailure) return Result.failure(error: remote.error!);
      } else {
        final res = await queuedActionLocalDatasource.createQueuedAction(
          QueuedActionModel(
            id: DateTime.now().millisecondsSinceEpoch,
            repository: 'UserRepositoryImpl',
            method: 'deleteUser',
            param: userId,
            isCritical: false,
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
  Future<Result<List<UserEntity>>> getUsers({String? search}) async {
    try {
      if (pingService.isConnected) {
        final remote = await userRemoteDatasource.getUsers(search: search);
        if (remote.isFailure) return Result.failure(error: remote.error!);
        return Result.success(data: remote.data!.map((e) => e.toEntity()).toList());
      }

      final local = await userLocalDatasource.getUsers(search: search);
      if (local.isFailure) return Result.failure(error: local.error!);
      return Result.success(data: local.data!.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<String>> resetPassword(String userId) async {
    if (!pingService.isConnected) {
      return Result.failure(error: 'Resetting a password requires an internet connection.');
    }

    return userRemoteDatasource.resetPassword(userId);
  }

  @override
  Future<Result<({String id, String generatedPassword})>> createEmployee(UserEntity employee) async {
    if (!pingService.isConnected) {
      return Result.failure(error: 'Creating an employee requires an internet connection.');
    }

    return userRemoteDatasource.createEmployee(UserModel.fromEntity(employee));
  }

  @override
  Future<Result<void>> updateUser(UserEntity user, {String? imageFilePath}) async {
    try {
      final local = await userLocalDatasource.updateUser(UserModel.fromEntity(user), imageFilePath: imageFilePath);
      if (local.isFailure) return Result.failure(error: local.error!);

      if (pingService.isConnected) {
        final remote = await userRemoteDatasource.updateUser(
          UserModel.fromEntity(user),
          imageFilePath: imageFilePath,
        );
        if (remote.isFailure) return Result.failure(error: remote.error!);
      } else {
        final res = await queuedActionLocalDatasource.createQueuedAction(
          QueuedActionModel(
            id: DateTime.now().millisecondsSinceEpoch,
            repository: 'UserRepositoryImpl',
            method: 'updateUser',
            param: jsonEncode({...UserModel.fromEntity(user).toJson(), 'imageFilePath': imageFilePath}),
            isCritical: false,
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
}

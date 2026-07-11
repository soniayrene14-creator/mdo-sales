import 'package:sqflite/sqflite.dart';

import '../../../core/common/result.dart';
import '../../../core/services/database/database_config.dart';
import '../../../core/services/database/database_service.dart';
import '../../models/user_model.dart';
import '../interfaces/user_datasource.dart';

class UserLocalDatasourceImpl extends UserDatasource {
  final DatabaseService _databaseService;

  UserLocalDatasourceImpl(this._databaseService);

  @override
  Future<Result<String>> createUser(UserModel user, {String? imageFilePath}) async {
    try {
      if (imageFilePath != null) user.imageUrl = imageFilePath;

      await _databaseService.database.insert(
        DatabaseConfig.userTableName,
        user.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // The id is returned by the remote API after create/update
      return Result.success(data: user.id);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> updateUser(UserModel user, {String? imageFilePath}) async {
    try {
      if (imageFilePath != null) user.imageUrl = imageFilePath;

      await _databaseService.database.update(
        DatabaseConfig.userTableName,
        user.toJson(),
        where: 'id = ?',
        whereArgs: [user.id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> deleteUser(String id) async {
    try {
      await _databaseService.database.delete(
        DatabaseConfig.userTableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<UserModel?>> getUser(String id) async {
    try {
      var res = await _databaseService.database.query(
        DatabaseConfig.userTableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (res.isEmpty) return Result.success(data: null);

      return Result.success(data: UserModel.fromJson(res.first));
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<UserModel>>> getUsers({String? search}) async {
    try {
      final res = await _databaseService.database.query(
        DatabaseConfig.userTableName,
        where: search != null && search.isNotEmpty ? 'name LIKE ?' : null,
        whereArgs: search != null && search.isNotEmpty ? ['%$search%'] : null,
      );

      return Result.success(data: res.map((e) => UserModel.fromJson(e)).toList());
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<String>> resetPassword(String id) async {
    return Result.failure(error: 'Resetting a password requires an internet connection.');
  }

  @override
  Future<Result<({String id, String generatedPassword})>> createEmployee(UserModel user) async {
    return Result.failure(error: 'Creating an employee requires an internet connection.');
  }
}

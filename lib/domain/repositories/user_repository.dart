import '../../core/common/result.dart';
import '../entities/user_entity.dart';

abstract class UserRepository {
  Future<Result<UserEntity?>> getUser(String userId);
  Future<Result<String>> createUser(UserEntity user, {String? imageFilePath});
  Future<Result<void>> updateUser(UserEntity user, {String? imageFilePath});
  Future<Result<UserEntity?>> getMe();
  Future<Result<void>> updateMe(UserEntity user, {String? imageFilePath});
  Future<Result<void>> deleteUser(String userId);
  Future<Result<List<UserEntity>>> getUsers({String? search});
  Future<Result<String>> resetPassword(String userId);
  Future<Result<({String id, String generatedPassword})>> createEmployee(UserEntity employee);
}

import '../../../core/common/result.dart';
import '../../models/user_model.dart';

abstract class UserDatasource {
  Future<Result<String>> createUser(UserModel user, {String? imageFilePath});

  Future<Result<void>> updateUser(UserModel user, {String? imageFilePath});

  Future<Result<void>> deleteUser(String id);

  Future<Result<UserModel?>> getUser(String id);

  Future<Result<List<UserModel>>> getUsers({String? search});

  Future<Result<String>> resetPassword(String id);

  Future<Result<({String id, String generatedPassword})>> createEmployee(UserModel user);
}

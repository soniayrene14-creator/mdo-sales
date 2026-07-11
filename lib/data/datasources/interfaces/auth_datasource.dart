import '../../../core/common/result.dart';
import '../../models/user_model.dart';

abstract class AuthDataSource {
  Future<Result<UserModel>> login(String email, String password);

  Future<Result<void>> signOut();

  Future<Result<UserModel?>> getCurrentUser();

  Future<Result<void>> changePassword(String oldPassword, String newPassword);

  Future<Result<String>> refreshAccessToken();

  String? get accessToken;

  String? get refreshToken;
}

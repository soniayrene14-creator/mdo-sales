import '../../../core/common/result.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_django_remote_datasource_impl.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDjangoRemoteDataSourceImpl _authRemoteDataSource;

  AuthRepositoryImpl(this._authRemoteDataSource);

  @override
  Future<Result<UserEntity>> login(String username, String password) async {
    final result = await _authRemoteDataSource.login(username, password);
    if (result.isFailure) return Result.failure(error: result.error!);
    return Result.success(data: result.data!.toEntity());
  }

  @override
  Future<Result<void>> signOut() async {
    final result = await _authRemoteDataSource.signOut();
    return result;
  }

  @override
  Future<Result<UserEntity?>> getCurrentUser() async {
    final result = await _authRemoteDataSource.getCurrentUser();
    if (result.isFailure) return Result.failure(error: result.error!);
    return Result.success(data: result.data?.toEntity());
  }

  @override
  Future<Result<void>> changePassword(String oldPassword, String newPassword) async {
    final result = await _authRemoteDataSource.changePassword(oldPassword, newPassword);
    return result;
  }

  @override
  String? get accessToken => _authRemoteDataSource.accessToken;

  @override
  String? get refreshToken => _authRemoteDataSource.refreshToken;
}

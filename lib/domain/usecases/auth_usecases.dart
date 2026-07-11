import '../../core/common/result.dart';
import '../../core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import 'params/login_params.dart';
import 'params/no_param.dart';

class LoginUsecase extends Usecase<Result, LoginParams> {
  LoginUsecase(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<Result<UserEntity>> call(LoginParams params) async =>
      _authRepository.login(params.email, params.password);
}

class SignOutUsecase extends Usecase<Result, NoParam> {
  SignOutUsecase(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<Result<void>> call(NoParam params) async => _authRepository.signOut();
}

class GetCurrentUserUsecase extends Usecase<Result, NoParam> {
  GetCurrentUserUsecase(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<Result<UserEntity?>> call(NoParam params) async => _authRepository.getCurrentUser();
}

class ChangePasswordUsecase extends Usecase<Result, ChangePasswordParams> {
  ChangePasswordUsecase(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<Result<void>> call(ChangePasswordParams params) async =>
      _authRepository.changePassword(params.oldPassword, params.newPassword);
}

class ChangePasswordParams {
  final String oldPassword;
  final String newPassword;

  const ChangePasswordParams({
    required this.oldPassword,
    required this.newPassword,
  });
}

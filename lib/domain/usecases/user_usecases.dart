import '../../core/common/result.dart';
import '../../core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

class GetUserUsecase extends Usecase<Result, String> {
  GetUserUsecase(this._userRepository);

  final UserRepository _userRepository;

  @override
  Future<Result<UserEntity?>> call(String params) async => _userRepository.getUser(params);
}

class CreateUserUsecase extends Usecase<Result, ({UserEntity user, String? imageFilePath})> {
  CreateUserUsecase(this._userRepository);

  final UserRepository _userRepository;

  @override
  Future<Result<String>> call(({UserEntity user, String? imageFilePath}) params) async {
    final currentUser = await _userRepository.getUser(params.user.id);

    if (currentUser.data != null) {
      return Result.success(data: currentUser.data!.id);
    }

    return await _userRepository.createUser(params.user, imageFilePath: params.imageFilePath);
  }
}

class UpateUserUsecase extends Usecase<Result<void>, ({UserEntity user, String? imageFilePath})> {
  UpateUserUsecase(this._userRepository);

  final UserRepository _userRepository;

  @override
  Future<Result<void>> call(({UserEntity user, String? imageFilePath}) params) async =>
      _userRepository.updateUser(params.user, imageFilePath: params.imageFilePath);
}

class DeleteUserUsecase extends Usecase<Result<void>, String> {
  DeleteUserUsecase(this._userRepository);

  final UserRepository _userRepository;

  @override
  Future<Result<void>> call(String params) async => _userRepository.deleteUser(params);
}

class GetUsersUsecase extends Usecase<Result, String?> {
  GetUsersUsecase(this._userRepository);

  final UserRepository _userRepository;

  @override
  Future<Result<List<UserEntity>>> call(String? params) async => _userRepository.getUsers(search: params);
}

class ResetUserPasswordUsecase extends Usecase<Result, String> {
  ResetUserPasswordUsecase(this._userRepository);

  final UserRepository _userRepository;

  @override
  Future<Result<String>> call(String params) async => _userRepository.resetPassword(params);
}

class CreateEmployeeUsecase extends Usecase<Result, UserEntity> {
  CreateEmployeeUsecase(this._userRepository);

  final UserRepository _userRepository;

  @override
  Future<Result<({String id, String generatedPassword})>> call(UserEntity params) async =>
      _userRepository.createEmployee(params);
}

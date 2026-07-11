import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../core/common/result.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/usecases/user_usecases.dart';
import 'employees_state.dart';

final employeesNotifierProvider = NotifierProvider<EmployeesNotifier, EmployeesState>(
  EmployeesNotifier.new,
);

class EmployeesNotifier extends Notifier<EmployeesState> {
  @override
  EmployeesState build() => const EmployeesState();

  Future<void> getEmployees({String? search}) async {
    state = state.copyWith(isLoading: true);

    final userRepository = ref.read(userRepositoryProvider);
    final res = await GetUsersUsecase(userRepository).call(search);

    state = state.copyWith(employees: res.data ?? [], isLoading: false);
  }

  Future<Result<String>> resetPassword(String userId) async {
    final userRepository = ref.read(userRepositoryProvider);
    return ResetUserPasswordUsecase(userRepository).call(userId);
  }

  Future<Result<({String id, String generatedPassword})>> createEmployee({
    required String username,
    required String name,
    required String email,
    required String phone,
    required String role,
  }) async {
    final userRepository = ref.read(userRepositoryProvider);

    final employee = UserEntity(
      id: '',
      username: username,
      name: name,
      email: email,
      phone: phone,
      role: role,
    );

    final res = await CreateEmployeeUsecase(userRepository).call(employee);
    if (res.isSuccess) await getEmployees();
    return res;
  }

  Future<Result<void>> updateEmployee(UserEntity employee) async {
    final userRepository = ref.read(userRepositoryProvider);
    final res = await UpateUserUsecase(userRepository).call((user: employee, imageFilePath: null));
    if (res.isSuccess) await getEmployees();
    return res;
  }

  Future<Result<void>> setEmployeeActive(UserEntity employee, bool isActive) async {
    return updateEmployee(employee.copyWith(isActive: isActive));
  }
}

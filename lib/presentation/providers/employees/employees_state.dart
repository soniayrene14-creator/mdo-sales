import '../../../domain/entities/user_entity.dart';

class EmployeesState {
  final List<UserEntity>? employees;
  final bool isLoading;

  const EmployeesState({this.employees, this.isLoading = false});

  EmployeesState copyWith({
    List<UserEntity>? employees,
    bool? isLoading,
  }) {
    return EmployeesState(
      employees: employees ?? this.employees,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../core/common/result.dart';
import '../../../domain/entities/admin_dashboard_entity.dart';
import '../../../domain/entities/employee_dashboard_entity.dart';
import '../../../domain/entities/sales_report_entity.dart';
import '../../../domain/usecases/dashboard_usecases.dart';
import '../../../domain/usecases/params/no_param.dart';
import 'dashboard_state.dart';

final dashboardNotifierProvider = NotifierProvider<DashboardNotifier, DashboardState>(
  DashboardNotifier.new,
);

class DashboardNotifier extends Notifier<DashboardState> {
  @override
  DashboardState build() {
    return const DashboardState();
  }

  Future<void> loadAdminDashboard() async {
    state = state.copyWith(isLoading: true);
    final repository = ref.read(dashboardRepositoryProvider);
    final result = await GetAdminDashboardUsecase(repository).call(NoParam());
    if (result.isSuccess) {
      state = state.copyWith(adminDashboard: result.data, isLoading: false);
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> loadEmployeeDashboard() async {
    state = state.copyWith(isLoading: true);
    final repository = ref.read(dashboardRepositoryProvider);
    final result = await GetEmployeeDashboardUsecase(repository).call(NoParam());
    if (result.isSuccess) {
      state = state.copyWith(employeeDashboard: result.data, isLoading: false);
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> loadSalesReport({String? start, String? end}) async {
    state = state.copyWith(isLoading: true);
    final repository = ref.read(dashboardRepositoryProvider);
    final result = await GetSalesReportUsecase(repository).call(SalesReportParams(start: start, end: end));
    if (result.isSuccess) {
      state = state.copyWith(salesReport: result.data, isLoading: false);
    } else {
      state = state.copyWith(isLoading: false);
    }
  }
}

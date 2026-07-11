import '../../core/common/result.dart';
import '../../core/usecase/usecase.dart';
import '../../domain/entities/admin_dashboard_entity.dart';
import '../../domain/entities/employee_dashboard_entity.dart';
import '../../domain/entities/sales_report_entity.dart';
import '../repositories/dashboard_repository.dart';
import 'params/no_param.dart';

class GetAdminDashboardUsecase extends Usecase<Result, NoParam> {
  GetAdminDashboardUsecase(this._dashboardRepository);

  final DashboardRepository _dashboardRepository;

  @override
  Future<Result<AdminDashboardEntity>> call(NoParam params) async => _dashboardRepository.getAdminDashboard();
}

class GetEmployeeDashboardUsecase extends Usecase<Result, NoParam> {
  GetEmployeeDashboardUsecase(this._dashboardRepository);

  final DashboardRepository _dashboardRepository;

  @override
  Future<Result<EmployeeDashboardEntity>> call(NoParam params) async => _dashboardRepository.getEmployeeDashboard();
}

class GetSalesReportUsecase extends Usecase<Result, SalesReportParams> {
  GetSalesReportUsecase(this._dashboardRepository);

  final DashboardRepository _dashboardRepository;

  @override
  Future<Result<SalesReportEntity>> call(SalesReportParams params) async =>
      _dashboardRepository.getSalesReport(start: params.start, end: params.end);
}

class SalesReportParams {
  final String? start;
  final String? end;

  const SalesReportParams({this.start, this.end});
}

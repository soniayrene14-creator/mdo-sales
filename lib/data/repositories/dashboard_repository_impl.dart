import '../../../core/common/result.dart';
import '../../../domain/entities/admin_dashboard_entity.dart';
import '../../../domain/entities/employee_dashboard_entity.dart';
import '../../../domain/entities/sales_report_entity.dart';
import '../../../domain/repositories/dashboard_repository.dart';
import '../datasources/remote/transaction_django_remote_datasource_impl.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final TransactionDjangoRemoteDataSourceImpl _remoteDataSource;

  DashboardRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<AdminDashboardEntity>> getAdminDashboard() async {
    final result = await _remoteDataSource.getAdminDashboard();
    if (result.isFailure) return Result.failure(error: result.error!);
    return Result.success(data: result.data!.toEntity());
  }

  @override
  Future<Result<EmployeeDashboardEntity>> getEmployeeDashboard() async {
    final result = await _remoteDataSource.getEmployeeDashboard();
    if (result.isFailure) return Result.failure(error: result.error!);
    return Result.success(data: result.data!.toEntity());
  }

  @override
  Future<Result<SalesReportEntity>> getSalesReport({String? start, String? end}) async {
    final result = await _remoteDataSource.getSalesReport(start: start, end: end);
    if (result.isFailure) return Result.failure(error: result.error!);
    return Result.success(data: result.data!.toEntity());
  }
}

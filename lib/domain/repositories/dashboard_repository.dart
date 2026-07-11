import '../../../core/common/result.dart';
import '../entities/admin_dashboard_entity.dart';
import '../entities/employee_dashboard_entity.dart';
import '../entities/sales_report_entity.dart';

abstract class DashboardRepository {
  Future<Result<AdminDashboardEntity>> getAdminDashboard();
  Future<Result<EmployeeDashboardEntity>> getEmployeeDashboard();
  Future<Result<SalesReportEntity>> getSalesReport({String? start, String? end});
}

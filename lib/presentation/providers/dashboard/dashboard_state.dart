import '../../../domain/entities/admin_dashboard_entity.dart';
import '../../../domain/entities/employee_dashboard_entity.dart';
import '../../../domain/entities/sales_report_entity.dart';

class DashboardState {
  final AdminDashboardEntity? adminDashboard;
  final EmployeeDashboardEntity? employeeDashboard;
  final SalesReportEntity? salesReport;
  final bool isLoading;

  const DashboardState({
    this.adminDashboard,
    this.employeeDashboard,
    this.salesReport,
    this.isLoading = false,
  });

  DashboardState copyWith({
    AdminDashboardEntity? adminDashboard,
    EmployeeDashboardEntity? employeeDashboard,
    SalesReportEntity? salesReport,
    bool? isLoading,
  }) {
    return DashboardState(
      adminDashboard: adminDashboard ?? this.adminDashboard,
      employeeDashboard: employeeDashboard ?? this.employeeDashboard,
      salesReport: salesReport ?? this.salesReport,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

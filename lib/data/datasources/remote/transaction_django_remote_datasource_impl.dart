import '../../../core/common/result.dart';
import '../../../core/services/api/api_client.dart';
import '../../models/transaction_model.dart';
import '../../models/sale_model.dart';
import '../../models/proforma_model.dart';
import '../../models/admin_dashboard_model.dart';
import '../../models/employee_dashboard_model.dart';
import '../../models/sales_report_model.dart';
import '../interfaces/transaction_datasource.dart';

class TransactionDjangoRemoteDataSourceImpl implements TransactionDatasource {
  final ApiClient apiClient;

  TransactionDjangoRemoteDataSourceImpl({required this.apiClient});

  List<TransactionModel> _parseList(dynamic json) {
    final results = json?['results'];
    if (results is List) {
      return results.map((e) => TransactionModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return <TransactionModel>[];
  }

  Map<String, dynamic> _toDjangoBody(TransactionModel transaction) {
    return {
      'customer_name': transaction.customerName,
      'customer_phone': transaction.customerPhone ?? '',
      'payment_method': transaction.paymentMethod,
      'received_amount': transaction.receivedAmount,
      'return_amount': transaction.returnAmount,
      'items_input': transaction.orderedProducts
          ?.map(
            (e) => {
              'product': e.productId,
              'quantity': e.quantity,
            },
          )
          .toList(),
    };
  }

  @override
  Future<Result<int>> createTransaction(TransactionModel transaction) async {
    try {
      final result = await apiClient.post<Map<String, dynamic>>(
        '/api/v1/sales/',
        _toDjangoBody(transaction),
        parser: (json) => json ?? <String, dynamic>{},
      );

      if (result.isFailure) {
        return Result.failure(error: result.error!);
      }

      return Result.success(data: result.data!['id'] as int);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> updateTransaction(TransactionModel transaction) async {
    try {
      final result = await apiClient.put<Map<String, dynamic>>(
        '/api/v1/sales/${transaction.id}/',
        _toDjangoBody(transaction),
        parser: (json) => json ?? <String, dynamic>{},
      );

      if (result.isFailure) {
        return Result.failure(error: result.error!);
      }

      return Result<void>.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> deleteTransaction(int id) async {
    try {
      final result = await apiClient.delete<Map<String, dynamic>>(
        '/api/v1/sales/$id/',
        parser: (json) => json ?? <String, dynamic>{},
      );

      if (result.isFailure) {
        return Result.failure(error: result.error!);
      }

      return Result<void>.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<TransactionModel?>> getTransaction(int id) async {
    try {
      final result = await apiClient.get<Map<String, dynamic>>(
        '/api/v1/sales/$id/',
        parser: (json) => json ?? <String, dynamic>{},
      );

      if (result.isFailure) {
        return Result.failure(error: result.error!);
      }

      final data = result.data!;
      if (data.isEmpty) {
        return Result.success(data: null);
      }

      return Result.success(data: TransactionModel.fromJson(data));
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<TransactionModel>>> getAllUserTransactions(String userId) async {
    try {
      final result = await apiClient.get<List<TransactionModel>>(
        '/api/v1/sales/',
        parser: _parseList,
      );

      if (result.isFailure) {
        return Result.failure(error: result.error!);
      }

      return Result.success(data: result.data ?? <TransactionModel>[]);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<TransactionModel>>> getUserTransactions(
    String userId, {
    String orderBy = '',
    String sortBy = '',
    int limit = 20,
    int? offset,
    String? contains,
  }) async {
    try {
      final query = <String, dynamic>{};
      if (contains != null && contains.isNotEmpty) {
        query['search'] = contains;
      }
      if (sortBy.isNotEmpty) {
        query['ordering'] = sortBy;
      } else if (orderBy.isNotEmpty) {
        query['ordering'] = orderBy;
      }
      if (limit > 0) {
        query['page'] = (offset != null && offset > 0 ? (offset ~/ limit) + 1 : 1).toString();
      }

      final result = await apiClient.get<List<TransactionModel>>(
        '/api/v1/sales/',
        query: query,
        parser: _parseList,
      );

      if (result.isFailure) {
        return Result.failure(error: result.error!);
      }

      return Result.success(data: result.data ?? <TransactionModel>[]);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  Future<Result<List<SaleModel>>> getAllSales() async {
    try {
      final result = await apiClient.get<List<SaleModel>>(
        '/api/v1/sales/',
        parser: _parseSaleList,
      );

      if (result.isFailure) {
        return Result.failure(error: result.error!);
      }

      return Result.success(data: result.data ?? <SaleModel>[]);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  Future<Result<SaleModel>> getSale(int saleId) async {
    try {
      final result = await apiClient.get<Map<String, dynamic>>(
        '/api/v1/sales/$saleId/',
        parser: (json) => json ?? <String, dynamic>{},
      );

      if (result.isFailure) {
        return Result.failure(error: result.error!);
      }

      return Result.success(data: SaleModel.fromJson(result.data!));
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  Future<Result<ProformaModel>> createProforma(ProformaModel proforma) async {
    try {
      final body = {
        'customer_name': proforma.customerName,
        'customer_phone': proforma.customerPhone ?? '',
        'items_input': proforma.items
            .map(
              (e) => {
                'product': e.productId,
                'quantity': e.quantity,
              },
            )
            .toList(),
      };

      final result = await apiClient.post<Map<String, dynamic>>(
        '/api/v1/proformas/',
        body,
        parser: (json) => json ?? <String, dynamic>{},
      );

      if (result.isFailure) {
        return Result.failure(error: result.error!);
      }

      return Result.success(data: ProformaModel.fromJson(result.data!));
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  Future<Result<List<ProformaModel>>> getAllProformas() async {
    try {
      final result = await apiClient.get<List<ProformaModel>>(
        '/api/v1/proformas/',
        parser: _parseProformaList,
      );

      if (result.isFailure) {
        return Result.failure(error: result.error!);
      }

      return Result.success(data: result.data ?? <ProformaModel>[]);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  Future<Result<ProformaModel>> getProforma(int proformaId) async {
    try {
      final result = await apiClient.get<Map<String, dynamic>>(
        '/api/v1/proformas/$proformaId/',
        parser: (json) => json ?? <String, dynamic>{},
      );

      if (result.isFailure) {
        return Result.failure(error: result.error!);
      }

      return Result.success(data: ProformaModel.fromJson(result.data!));
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  Future<Result<AdminDashboardModel>> getAdminDashboard() async {
    try {
      final result = await apiClient.get<Map<String, dynamic>>(
        '/api/v1/dashboard/admin/',
        parser: (json) => json ?? <String, dynamic>{},
      );

      if (result.isFailure) {
        return Result.failure(error: result.error!);
      }

      return Result.success(data: AdminDashboardModel.fromJson(result.data!));
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  Future<Result<EmployeeDashboardModel>> getEmployeeDashboard() async {
    try {
      final result = await apiClient.get<Map<String, dynamic>>(
        '/api/v1/dashboard/employee/',
        parser: (json) => json ?? <String, dynamic>{},
      );

      if (result.isFailure) {
        return Result.failure(error: result.error!);
      }

      return Result.success(data: EmployeeDashboardModel.fromJson(result.data!));
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  Future<Result<SalesReportModel>> getSalesReport({String? start, String? end}) async {
    try {
      final query = <String, dynamic>{};
      if (start != null && start.isNotEmpty) query['start'] = start;
      if (end != null && end.isNotEmpty) query['end'] = end;

      final result = await apiClient.get<Map<String, dynamic>>(
        '/api/v1/dashboard/reports/sales/',
        query: query,
        parser: (json) => json ?? <String, dynamic>{},
      );

      if (result.isFailure) {
        return Result.failure(error: result.error!);
      }

      return Result.success(data: SalesReportModel.fromJson(result.data!));
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  List<SaleModel> _parseSaleList(dynamic json) {
    final results = json?['results'];
    if (results is List) {
      return results.map((e) => SaleModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return <SaleModel>[];
  }

  List<ProformaModel> _parseProformaList(dynamic json) {
    final results = json?['results'];
    if (results is List) {
      return results.map((e) => ProformaModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return <ProformaModel>[];
  }
}

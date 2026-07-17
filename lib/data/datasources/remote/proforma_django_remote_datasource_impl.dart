import '../../../core/common/result.dart';
import '../../../core/services/api/api_client.dart';
import '../../models/proforma_model.dart';
import '../interfaces/proforma_datasource.dart';

class ProformaDjangoRemoteDataSourceImpl implements ProformaDatasource {
  final ApiClient apiClient;

  ProformaDjangoRemoteDataSourceImpl({required this.apiClient});

  List<ProformaModel> _parseList(dynamic json) {
    final results = json?['results'];
    if (results is List) {
      return results.map((e) => ProformaModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return <ProformaModel>[];
  }

  /// Fields matching ProformaSerializer's writable fields: `items_input` is a
  /// list of `{product, quantity}`, `unit_price` and `total_amount` are
  /// computed server-side from the product's current price.
  Map<String, dynamic> _toDjangoBody(ProformaModel proforma) {
    return {
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
  }

  @override
  Future<Result<ProformaModel>> createProforma(ProformaModel proforma) async {
    try {
      final result = await apiClient.post<Map<String, dynamic>>(
        '/api/v1/proformas/',
        _toDjangoBody(proforma),
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

  @override
  Future<Result<List<ProformaModel>>> getAllProformas() async {
    try {
      final result = await apiClient.get<List<ProformaModel>>(
        '/api/v1/proformas/',
        parser: _parseList,
      );

      if (result.isFailure) {
        return Result.failure(error: result.error!);
      }

      return Result.success(data: result.data ?? <ProformaModel>[]);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
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

  @override
  Future<Result<ProformaModel>> updateProforma(ProformaModel proforma) async {
    try {
      final result = await apiClient.put<Map<String, dynamic>>(
        '/api/v1/proformas/${proforma.id}/',
        _toDjangoBody(proforma),
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

  @override
  Future<Result<void>> deleteProforma(int proformaId) async {
    try {
      final result = await apiClient.delete<void>('/api/v1/proformas/$proformaId/');

      if (result.isFailure) {
        return Result.failure(error: result.error!);
      }

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }
}

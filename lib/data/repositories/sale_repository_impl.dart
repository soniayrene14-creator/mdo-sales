import '../../../core/common/result.dart';
import '../../../domain/entities/proforma_entity.dart';
import '../../../domain/entities/sale_entity.dart';
import '../../../domain/repositories/proforma_repository.dart';
import '../../../domain/repositories/sale_repository.dart';
import '../../../domain/repositories/stock_repository.dart';
import '../models/proforma_model.dart';
import '../datasources/remote/transaction_django_remote_datasource_impl.dart';

class SaleRepositoryImpl implements SaleRepository {
  final TransactionDjangoRemoteDataSourceImpl _remoteDataSource;

  SaleRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<SaleEntity>>> getAllSales() async {
    final result = await _remoteDataSource.getAllSales();
    if (result.isFailure) return Result.failure(error: result.error!);
    final sales = result.data!.map((e) => e.toEntity()).toList();
    return Result.success(data: sales);
  }

  @override
  Future<Result<SaleEntity>> getSale(int saleId) async {
    final result = await _remoteDataSource.getSale(saleId);
    if (result.isFailure) return Result.failure(error: result.error!);
    return Result.success(data: result.data!.toEntity());
  }
}

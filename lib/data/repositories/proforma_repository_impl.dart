import '../../../core/common/result.dart';
import '../../../domain/entities/proforma_entity.dart';
import '../../../domain/repositories/proforma_repository.dart';
import '../models/proforma_model.dart';
import '../datasources/remote/proforma_django_remote_datasource_impl.dart';

class ProformaRepositoryImpl implements ProformaRepository {
  final ProformaDjangoRemoteDataSourceImpl _remoteDataSource;

  ProformaRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<ProformaEntity>>> getAllProformas() async {
    final result = await _remoteDataSource.getAllProformas();
    if (result.isFailure) return Result.failure(error: result.error!);
    final proformas = result.data!.map((e) => e.toEntity()).toList();
    return Result.success(data: proformas);
  }

  @override
  Future<Result<ProformaEntity>> getProforma(int proformaId) async {
    final result = await _remoteDataSource.getProforma(proformaId);
    if (result.isFailure) return Result.failure(error: result.error!);
    return Result.success(data: result.data!.toEntity());
  }

  @override
  Future<Result<ProformaEntity>> createProforma(ProformaEntity proforma) async {
    final model = ProformaModel.fromEntity(proforma);
    final result = await _remoteDataSource.createProforma(model);
    if (result.isFailure) return Result.failure(error: result.error!);
    return Result.success(data: result.data!.toEntity());
  }

  @override
  Future<Result<ProformaEntity>> updateProforma(ProformaEntity proforma) async {
    final model = ProformaModel.fromEntity(proforma);
    final result = await _remoteDataSource.updateProforma(model);
    if (result.isFailure) return Result.failure(error: result.error!);
    return Result.success(data: result.data!.toEntity());
  }

  @override
  Future<Result<void>> deleteProforma(int proformaId) async {
    return _remoteDataSource.deleteProforma(proformaId);
  }
}

import '../../core/common/result.dart';
import '../../core/usecase/usecase.dart';
import '../../domain/entities/proforma_entity.dart';
import '../repositories/proforma_repository.dart';
import 'params/no_param.dart';

class GetAllProformasUsecase extends Usecase<Result, NoParam> {
  GetAllProformasUsecase(this._proformaRepository);

  final ProformaRepository _proformaRepository;

  @override
  Future<Result<List<ProformaEntity>>> call(NoParam params) async => _proformaRepository.getAllProformas();
}

class GetProformaUsecase extends Usecase<Result, int> {
  GetProformaUsecase(this._proformaRepository);

  final ProformaRepository _proformaRepository;

  @override
  Future<Result<ProformaEntity>> call(int params) async => _proformaRepository.getProforma(params);
}

class CreateProformaUsecase extends Usecase<Result, ProformaEntity> {
  CreateProformaUsecase(this._proformaRepository);

  final ProformaRepository _proformaRepository;

  @override
  Future<Result<ProformaEntity>> call(ProformaEntity params) async => _proformaRepository.createProforma(params);
}

class UpdateProformaUsecase extends Usecase<Result, ProformaEntity> {
  UpdateProformaUsecase(this._proformaRepository);

  final ProformaRepository _proformaRepository;

  @override
  Future<Result<ProformaEntity>> call(ProformaEntity params) async => _proformaRepository.updateProforma(params);
}

class DeleteProformaUsecase extends Usecase<Result<void>, int> {
  DeleteProformaUsecase(this._proformaRepository);

  final ProformaRepository _proformaRepository;

  @override
  Future<Result<void>> call(int params) async => _proformaRepository.deleteProforma(params);
}

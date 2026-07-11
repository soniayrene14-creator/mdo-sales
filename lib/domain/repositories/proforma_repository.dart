import '../../../core/common/result.dart';
import '../entities/proforma_entity.dart';

abstract class ProformaRepository {
  Future<Result<List<ProformaEntity>>> getAllProformas();
  Future<Result<ProformaEntity>> getProforma(int proformaId);
  Future<Result<ProformaEntity>> createProforma(ProformaEntity proforma);
}

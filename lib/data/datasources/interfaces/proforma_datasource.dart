import '../../../core/common/result.dart';
import '../../models/proforma_model.dart';

abstract class ProformaDatasource {
  Future<Result<ProformaModel>> createProforma(ProformaModel proforma);

  Future<Result<List<ProformaModel>>> getAllProformas();

  Future<Result<ProformaModel>> getProforma(int proformaId);

  Future<Result<ProformaModel>> updateProforma(ProformaModel proforma);

  Future<Result<void>> deleteProforma(int proformaId);
}

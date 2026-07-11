import '../../../core/common/result.dart';
import '../entities/proforma_entity.dart';
import '../entities/sale_entity.dart';

abstract class SaleRepository {
  Future<Result<List<SaleEntity>>> getAllSales();
  Future<Result<SaleEntity>> getSale(int saleId);
}

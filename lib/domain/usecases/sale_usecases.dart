import '../../core/common/result.dart';
import '../../core/usecase/usecase.dart';
import '../../domain/entities/sale_entity.dart';
import '../repositories/sale_repository.dart';
import 'params/no_param.dart';

class GetAllSalesUsecase extends Usecase<Result, NoParam> {
  GetAllSalesUsecase(this._saleRepository);

  final SaleRepository _saleRepository;

  @override
  Future<Result<List<SaleEntity>>> call(NoParam params) async => _saleRepository.getAllSales();
}

class GetSaleUsecase extends Usecase<Result, int> {
  GetSaleUsecase(this._saleRepository);

  final SaleRepository _saleRepository;

  @override
  Future<Result<SaleEntity>> call(int params) async => _saleRepository.getSale(params);
}

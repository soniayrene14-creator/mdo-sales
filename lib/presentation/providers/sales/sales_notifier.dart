import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../core/common/result.dart';
import '../../../domain/entities/sale_entity.dart';
import '../../../domain/usecases/params/no_param.dart';
import '../../../domain/usecases/sale_usecases.dart';
import 'sales_state.dart';

final salesNotifierProvider = NotifierProvider<SalesNotifier, SalesState>(
  SalesNotifier.new,
);

class SalesNotifier extends Notifier<SalesState> {
  @override
  SalesState build() {
    return const SalesState();
  }

  Future<void> loadSales() async {
    state = state.copyWith(isLoading: true);
    final repository = ref.read(saleRepositoryProvider);
    final result = await GetAllSalesUsecase(repository).call(NoParam());
    if (result.isSuccess) {
      state = state.copyWith(sales: result.data, isLoading: false);
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> loadSaleDetail(int saleId) async {
    state = state.copyWith(isLoading: true);
    final repository = ref.read(saleRepositoryProvider);
    final result = await GetSaleUsecase(repository).call(saleId);
    if (result.isSuccess) {
      state = state.copyWith(selectedSale: result.data, isLoading: false);
    } else {
      state = state.copyWith(isLoading: false);
    }
  }
}

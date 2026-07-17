import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../core/common/result.dart';
import '../../../domain/usecases/params/no_param.dart';
import '../../../domain/usecases/proforma_usecases.dart';
import 'proformas_state.dart';

final proformasNotifierProvider = NotifierProvider<ProformasNotifier, ProformasState>(
  ProformasNotifier.new,
);

class ProformasNotifier extends Notifier<ProformasState> {
  @override
  ProformasState build() {
    return const ProformasState();
  }

  Future<void> loadProformas() async {
    state = state.copyWith(isLoading: true);
    final repository = ref.read(proformaRepositoryProvider);
    final result = await GetAllProformasUsecase(repository).call(NoParam());
    if (result.isSuccess) {
      state = state.copyWith(proformas: result.data, isLoading: false);
    } else {
      state = state.copyWith(isLoading: false, error: result.error?.toString());
    }
  }

  Future<void> loadProformaDetail(int proformaId) async {
    state = state.copyWith(isLoading: true);
    final repository = ref.read(proformaRepositoryProvider);
    final result = await GetProformaUsecase(repository).call(proformaId);
    if (result.isSuccess) {
      state = state.copyWith(selectedProforma: result.data, isLoading: false);
    } else {
      state = state.copyWith(isLoading: false, error: result.error?.toString());
    }
  }

  Future<Result<void>> deleteProforma(int proformaId) async {
    final repository = ref.read(proformaRepositoryProvider);
    final result = await DeleteProformaUsecase(repository).call(proformaId);

    if (result.isSuccess) {
      state = state.copyWith(proformas: state.proformas?.where((e) => e.id != proformaId).toList());
    }

    return result;
  }
}

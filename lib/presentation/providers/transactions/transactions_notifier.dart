import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../domain/usecases/params/base_params.dart';
import '../../../domain/usecases/transaction_usecases.dart';
import '../auth/auth_notifier.dart';
import 'transactions_state.dart';

final transactionsNotifierProvider = NotifierProvider<TransactionsNotifier, TransactionsState>(
  TransactionsNotifier.new,
);

class TransactionsNotifier extends Notifier<TransactionsState> {
  @override
  TransactionsState build() {
    return const TransactionsState();
  }

  String _requireUserId() {
    final authState = ref.read(authNotifierProvider);
    if (authState.isAuthenticated) return authState.user!.id;
    throw 'Non authentifié !';
  }

  void resetTransactions() {
    state = const TransactionsState();
  }

  Future<void> getAllTransactions({int? offset, String? contains}) async {
    final userId = _requireUserId();

    if (offset != null) {
      state = state.copyWith(isLoadingMore: true);
    }

    var params = BaseParams(
      param: userId,
      offset: offset,
      contains: contains,
    );

    final transactionRepository = ref.read(transactionRepositoryProvider);
    var res = await GetUserTransactionsUsecase(transactionRepository).call(params);

    if (res.isSuccess) {
      if (offset == null) {
        state = state.copyWith(allTransactions: res.data ?? [], isLoadingMore: false);
      } else {
        final current = state.allTransactions ?? [];
        state = state.copyWith(
          allTransactions: [...current, ...res.data ?? []],
          isLoadingMore: false,
        );
      }
    } else {
      state = state.copyWith(isLoadingMore: false);

      // Only the initial load is a genuine failure worth surfacing. Paging
      // past the last page is expected (the API 404s once there's nothing
      // left) and must not blow up as an uncaught error while scrolling.
      if (offset == null) {
        throw res.error ?? 'Échec du chargement des données';
      }
    }
  }
}

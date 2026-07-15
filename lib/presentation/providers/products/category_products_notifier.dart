import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../domain/usecases/params/base_params.dart';
import '../../../domain/usecases/product_usecases.dart';
import '../auth/auth_notifier.dart';
import 'category_products_state.dart';

final categoryProductsNotifierProvider = NotifierProvider.autoDispose<CategoryProductsNotifier, CategoryProductsState>(
  CategoryProductsNotifier.new,
);

class CategoryProductsNotifier extends AutoDisposeNotifier<CategoryProductsState> {
  @override
  CategoryProductsState build() {
    return const CategoryProductsState();
  }

  String _requireUserId() {
    final authState = ref.read(authNotifierProvider);
    if (authState.isAuthenticated) return authState.user!.id;
    throw 'Non authentifié !';
  }

  Future<void> getProducts(int categoryId, {int? offset, String? contains}) async {
    final userId = _requireUserId();

    if (offset != null) {
      state = state.copyWith(isLoadingMore: true);
    }

    final params = BaseParams(
      param: userId,
      offset: offset,
      contains: contains,
      categoryId: categoryId,
    );

    final productRepository = ref.read(productRepositoryProvider);
    final res = await GetUserProductsUsecase(productRepository).call(params);

    if (res.isSuccess) {
      if (offset == null) {
        state = state.copyWith(products: res.data ?? [], isLoadingMore: false);
      } else {
        final current = state.products ?? [];
        state = state.copyWith(products: [...current, ...res.data ?? []], isLoadingMore: false);
      }
    } else {
      state = state.copyWith(isLoadingMore: false);

      if (offset == null) {
        throw Exception(res.error?.toString() ?? 'Échec du chargement des données');
      }
    }
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../core/common/result.dart';
import '../../../domain/usecases/params/base_params.dart';
import '../../../domain/usecases/params/no_param.dart';
import '../../../domain/usecases/product_usecases.dart';
import '../auth/auth_notifier.dart';
import 'products_state.dart';

final productsNotifierProvider = NotifierProvider<ProductsNotifier, ProductsState>(
  ProductsNotifier.new,
);

class ProductsNotifier extends Notifier<ProductsState> {
  @override
  ProductsState build() {
    return const ProductsState();
  }

  String _requireUserId() {
    final authState = ref.read(authNotifierProvider);
    if (authState.isAuthenticated) return authState.user!.id;
    throw 'Non authentifié !';
  }

  void resetProducts() {
    state = const ProductsState();
  }

  Future<void> getAllProducts({int? offset, String? contains}) async {
    final userId = _requireUserId();

    if (offset != null) {
      state = state.copyWith(isLoadingMore: true);
    }

    var params = BaseParams(
      param: userId,
      offset: offset,
      contains: contains,
    );

    final productRepository = ref.read(productRepositoryProvider);
    var res = await GetUserProductsUsecase(productRepository).call(params);

    if (res.isSuccess) {
      if (offset == null) {
        state = state.copyWith(allProducts: res.data ?? [], isLoadingMore: false);
      } else {
        final current = state.allProducts ?? [];
        state = state.copyWith(
          allProducts: [...current, ...res.data ?? []],
          isLoadingMore: false,
        );
      }
    } else {
      state = state.copyWith(isLoadingMore: false);

      // Only the initial load is a genuine failure worth surfacing. Paging
      // past the last page is expected (the API 404s once there's nothing
      // left) and must not blow up as an uncaught error while scrolling.
      if (offset == null) {
        throw Exception(res.error?.toString() ?? 'Échec du chargement des données');
      }
    }
  }

  Future<void> getLowStockProducts() async {
    state = state.copyWith(isLoadingTab: true);

    final productRepository = ref.read(productRepositoryProvider);
    final res = await GetLowStockProductsUsecase(productRepository).call(NoParam());

    state = state.copyWith(lowStockProducts: res.data ?? [], isLoadingTab: false);
  }

  Future<void> getOutOfStockProducts() async {
    state = state.copyWith(isLoadingTab: true);

    final productRepository = ref.read(productRepositoryProvider);
    final res = await GetOutOfStockProductsUsecase(productRepository).call(NoParam());

    state = state.copyWith(outOfStockProducts: res.data ?? [], isLoadingTab: false);
  }

  Future<void> getInactiveProducts() async {
    state = state.copyWith(isLoadingTab: true);

    final productRepository = ref.read(productRepositoryProvider);
    final res = await GetInactiveProductsUsecase(productRepository).call(NoParam());

    state = state.copyWith(inactiveProducts: res.data ?? [], isLoadingTab: false);
  }

  Future<Result<void>> reactivateProduct(int productId) async {
    final productRepository = ref.read(productRepositoryProvider);
    final res = await ReactivateProductUsecase(productRepository).call(productId);

    if (res.isFailure) return Result.failure(error: res.error!);

    await getInactiveProducts();

    return Result.success(data: null);
  }
}

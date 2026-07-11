import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../core/common/result.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/usecases/category_usecases.dart';
import '../../../domain/usecases/params/no_param.dart';
import '../../../domain/usecases/product_usecases.dart';
import '../auth/auth_notifier.dart';
import 'product_form_state.dart';
import 'products_notifier.dart';

final productFormNotifierProvider = NotifierProvider.autoDispose<ProductFormNotifier, ProductFormState>(
  ProductFormNotifier.new,
);

class ProductFormNotifier extends AutoDisposeNotifier<ProductFormState> {
  @override
  ProductFormState build() {
    return const ProductFormState();
  }

  String _requireUserId() {
    final authState = ref.read(authNotifierProvider);
    if (authState.isAuthenticated) return authState.user!.id;
    throw 'Non authentifié !';
  }

  Future<void> initProductForm(int? productId) async {
    final categoryRepository = ref.read(categoryRepositoryProvider);
    final categoriesRes = await GetAllCategoriesUsecase(categoryRepository).call(NoParam());
    state = state.copyWith(categories: categoriesRes.data ?? []);

    if (productId == null) {
      state = state.copyWith(isLoaded: true);
      return;
    }

    final productRepository = ref.read(productRepositoryProvider);
    var res = await GetProductUsecase(productRepository).call(productId);

    if (res.isSuccess) {
      var product = res.data;

      state = state.copyWith(
        imageUrl: product?.imageUrl,
        name: product?.name,
        price: product?.price,
        stock: product?.stock,
        description: product?.description,
        categoryId: product?.categoryId,
        isLoaded: true,
      );
    } else {
      throw res.error ?? 'Échec du chargement des données';
    }
  }

  Future<Result<int>> createProduct() async {
    try {
      final userId = _requireUserId();
      final productRepository = ref.read(productRepositoryProvider);

      var product = ProductEntity(
        createdById: userId,
        name: state.name ?? '',
        imageUrl: state.imageUrl ?? '',
        stock: state.stock ?? 0,
        price: state.price ?? 0,
        description: state.description ?? '',
        categoryId: state.categoryId,
      );

      var res = await CreateProductUsecase(
        productRepository,
      ).call((product: product, imageFilePath: state.imageFile?.path));

      // Refresh products
      ref.read(productsNotifierProvider.notifier).getAllProducts();

      return res;
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  Future<Result<void>> updatedProduct(int id) async {
    try {
      final userId = _requireUserId();
      final productRepository = ref.read(productRepositoryProvider);

      var product = ProductEntity(
        id: id,
        createdById: userId,
        name: state.name!,
        imageUrl: state.imageUrl ?? '',
        stock: state.stock ?? 0,
        price: state.price ?? 0,
        description: state.description ?? '',
        categoryId: state.categoryId,
      );

      var res = await UpdateProductUsecase(
        productRepository,
      ).call((product: product, imageFilePath: state.imageFile?.path));

      // Refresh products
      ref.read(productsNotifierProvider.notifier).getAllProducts();

      return res;
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  Future<Result<void>> deleteProduct(int id) async {
    try {
      final productRepository = ref.read(productRepositoryProvider);
      var res = await DeleteProductUsecase(productRepository).call(id);

      // Refresh products
      ref.read(productsNotifierProvider.notifier).getAllProducts();

      return res;
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  void onChangedImage(File value) {
    state = state.copyWith(imageFile: value);
  }

  void onChangedName(String value) {
    state = state.copyWith(name: value);
  }

  void onChangedPrice(String value) {
    state = state.copyWith(price: int.tryParse(value));
  }

  void onChangedStock(String value) {
    state = state.copyWith(stock: int.tryParse(value));
  }

  void onChangedDesc(String value) {
    state = state.copyWith(description: value);
  }

  void onChangedCategory(int categoryId) {
    state = state.copyWith(categoryId: categoryId);
  }
}

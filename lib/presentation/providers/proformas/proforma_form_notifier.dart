import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../core/common/result.dart';
import '../../../domain/entities/ordered_product_entity.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/entities/proforma_entity.dart';
import '../../../domain/entities/proforma_item_entity.dart';
import '../../../domain/usecases/proforma_usecases.dart';
import '../products/products_notifier.dart';
import 'proforma_form_state.dart';

final proformaFormNotifierProvider = NotifierProvider.autoDispose<ProformaFormNotifier, ProformaFormState>(
  ProformaFormNotifier.new,
);

class ProformaFormNotifier extends AutoDisposeNotifier<ProformaFormState> {
  @override
  ProformaFormState build() => const ProformaFormState();

  Future<void> initProformaForm(int? proformaId) async {
    await ref.read(productsNotifierProvider.notifier).getAllProducts();

    if (proformaId == null) {
      state = state.copyWith(isLoaded: true);
      return;
    }

    final proformaRepository = ref.read(proformaRepositoryProvider);
    final res = await GetProformaUsecase(proformaRepository).call(proformaId);

    if (res.isSuccess) {
      final proforma = res.data!;

      state = state.copyWith(
        customerName: proforma.customerName,
        customerPhone: proforma.customerPhone,
        items: proforma.items
            .map(
              (e) => OrderedProductEntity(
                id: e.id,
                productId: e.productId,
                quantity: e.quantity,
                stock: 0,
                name: e.productName,
                imageUrl: '',
                price: e.unitPrice,
              ),
            )
            .toList(),
        isLoaded: true,
      );
    } else {
      throw res.error ?? 'Échec du chargement des données';
    }
  }

  void onChangedSelectedProduct(int? productId) {
    state = state.copyWith(selectedProductId: productId, pickerQuantity: 1);
  }

  void onChangedPickerQuantity(int quantity) {
    state = state.copyWith(pickerQuantity: quantity < 1 ? 1 : quantity);
  }

  void addSelectedProductToCart(ProductEntity product) {
    final items = [...state.items];
    final currentIndex = items.indexWhere((e) => e.productId == product.id);
    final quantity = state.pickerQuantity;

    if (currentIndex != -1) {
      items[currentIndex] = items[currentIndex].copyWith(quantity: items[currentIndex].quantity + quantity);
    } else {
      items.add(
        OrderedProductEntity(
          id: DateTime.now().millisecondsSinceEpoch,
          productId: product.id!,
          quantity: quantity,
          stock: product.stock,
          name: product.name,
          imageUrl: product.imageUrl,
          price: product.price,
        ),
      );
    }

    state = ProformaFormState(
      items: items,
      customerName: state.customerName,
      customerPhone: state.customerPhone,
      isLoaded: state.isLoaded,
    );
  }

  void onRemoveOrderedProduct(OrderedProductEntity item) {
    state = state.copyWith(items: state.items.where((e) => e != item).toList());
  }

  void onChangedCustomerName(String value) {
    state = state.copyWith(customerName: value);
  }

  void onChangedCustomerPhone(String value) {
    state = state.copyWith(customerPhone: value);
  }

  void reset() {
    state = const ProformaFormState();
  }

  int getTotalAmount() {
    if (state.items.isEmpty) return 0;
    return state.items.map((e) => e.price * e.quantity).reduce((a, b) => a + b);
  }

  List<ProformaItemEntity> _buildItems() {
    return state.items
        .map(
          (e) => ProformaItemEntity(
            id: e.id ?? 0,
            productId: e.productId,
            productName: e.name,
            quantity: e.quantity,
            unitPrice: e.price,
            subtotal: e.price * e.quantity,
          ),
        )
        .toList();
  }

  Future<Result<int>> createProforma() async {
    if (state.items.isEmpty) {
      return Result.failure(error: 'Ajoutez au moins un produit.');
    }

    final proforma = ProformaEntity(
      id: 0,
      proformaNumber: '',
      sellerId: 0,
      customerName: state.customerName,
      customerPhone: state.customerPhone,
      items: _buildItems(),
      totalAmount: getTotalAmount(),
    );

    final repository = ref.read(proformaRepositoryProvider);
    final res = await CreateProformaUsecase(repository).call(proforma);

    if (res.isFailure) return Result.failure(error: res.error!);

    reset();

    return Result.success(data: res.data!.id);
  }

  Future<Result<int>> updateProforma(int id) async {
    if (state.items.isEmpty) {
      return Result.failure(error: 'Ajoutez au moins un produit.');
    }

    final proforma = ProformaEntity(
      id: id,
      proformaNumber: '',
      sellerId: 0,
      customerName: state.customerName,
      customerPhone: state.customerPhone,
      items: _buildItems(),
      totalAmount: getTotalAmount(),
    );

    final repository = ref.read(proformaRepositoryProvider);
    final res = await UpdateProformaUsecase(repository).call(proforma);

    if (res.isFailure) return Result.failure(error: res.error!);

    reset();

    return Result.success(data: res.data!.id);
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../core/common/result.dart';
import '../../../domain/entities/ordered_product_entity.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/entities/proforma_entity.dart';
import '../../../domain/entities/proforma_item_entity.dart';
import '../../../domain/usecases/proforma_usecases.dart';
import 'proforma_form_state.dart';

final proformaFormNotifierProvider = NotifierProvider.autoDispose<ProformaFormNotifier, ProformaFormState>(
  ProformaFormNotifier.new,
);

class ProformaFormNotifier extends AutoDisposeNotifier<ProformaFormState> {
  @override
  ProformaFormState build() => const ProformaFormState();

  void onAddOrderedProduct(ProductEntity product, int qty) {
    final items = [...state.items];
    final currentIndex = items.indexWhere((e) => e.productId == product.id);

    if (currentIndex != -1) {
      items[currentIndex] = items[currentIndex].copyWith(quantity: qty);
    } else {
      items.add(
        OrderedProductEntity(
          id: DateTime.now().millisecondsSinceEpoch,
          productId: product.id!,
          quantity: qty,
          stock: product.stock,
          name: product.name,
          imageUrl: product.imageUrl,
          price: product.price,
        ),
      );
    }

    state = state.copyWith(items: items);
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

  Future<Result<int>> submit() async {
    if (state.items.isEmpty) {
      return Result.failure(error: 'Ajoutez au moins un produit.');
    }

    final items = state.items
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

    final proforma = ProformaEntity(
      id: 0,
      proformaNumber: '',
      sellerId: 0,
      customerName: state.customerName,
      customerPhone: state.customerPhone,
      items: items,
      totalAmount: getTotalAmount(),
    );

    final repository = ref.read(proformaRepositoryProvider);
    final res = await CreateProformaUsecase(repository).call(proforma);

    if (res.isFailure) return Result.failure(error: res.error!);

    reset();

    return Result.success(data: res.data!.id);
  }
}

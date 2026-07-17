import '../../../domain/entities/ordered_product_entity.dart';

class ProformaFormState {
  final List<OrderedProductEntity> items;
  final String? customerName;
  final String? customerPhone;
  final int? selectedProductId;
  final int pickerQuantity;
  final bool isLoaded;

  const ProformaFormState({
    this.items = const [],
    this.customerName,
    this.customerPhone,
    this.selectedProductId,
    this.pickerQuantity = 1,
    this.isLoaded = false,
  });

  ProformaFormState copyWith({
    List<OrderedProductEntity>? items,
    String? customerName,
    String? customerPhone,
    int? selectedProductId,
    int? pickerQuantity,
    bool? isLoaded,
  }) {
    return ProformaFormState(
      items: items ?? this.items,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      selectedProductId: selectedProductId ?? this.selectedProductId,
      pickerQuantity: pickerQuantity ?? this.pickerQuantity,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}

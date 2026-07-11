import '../../../domain/entities/ordered_product_entity.dart';

class ProformaFormState {
  final List<OrderedProductEntity> items;
  final String? customerName;
  final String? customerPhone;

  const ProformaFormState({
    this.items = const [],
    this.customerName,
    this.customerPhone,
  });

  ProformaFormState copyWith({
    List<OrderedProductEntity>? items,
    String? customerName,
    String? customerPhone,
  }) {
    return ProformaFormState(
      items: items ?? this.items,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
    );
  }
}

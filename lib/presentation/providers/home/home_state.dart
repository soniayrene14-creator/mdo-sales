import '../../../domain/entities/ordered_product_entity.dart';

class HomeState {
  final List<OrderedProductEntity> orderedProducts;
  final int receivedAmount;
  final String selectedPaymentMethod;
  final String? customerName;
  final String? customerPhone;
  final String? description;
  final bool isPanelExpanded;

  const HomeState({
    this.orderedProducts = const [],
    this.receivedAmount = 0,
    this.selectedPaymentMethod = 'especes',
    this.customerName,
    this.customerPhone,
    this.description,
    this.isPanelExpanded = false,
  });

  HomeState copyWith({
    List<OrderedProductEntity>? orderedProducts,
    int? receivedAmount,
    String? selectedPaymentMethod,
    String? customerName,
    String? customerPhone,
    String? description,
    bool? isPanelExpanded,
  }) {
    return HomeState(
      orderedProducts: orderedProducts ?? this.orderedProducts,
      receivedAmount: receivedAmount ?? this.receivedAmount,
      selectedPaymentMethod: selectedPaymentMethod ?? this.selectedPaymentMethod,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      description: description ?? this.description,
      isPanelExpanded: isPanelExpanded ?? this.isPanelExpanded,
    );
  }
}

import '../../../domain/entities/proforma_entity.dart';

class ProformasState {
  final List<ProformaEntity>? proformas;
  final ProformaEntity? selectedProforma;
  final bool isLoading;
  final String? error;

  const ProformasState({
    this.proformas,
    this.selectedProforma,
    this.isLoading = false,
    this.error,
  });

  ProformasState copyWith({
    List<ProformaEntity>? proformas,
    ProformaEntity? selectedProforma,
    bool? isLoading,
    String? error,
  }) {
    return ProformasState(
      proformas: proformas ?? this.proformas,
      selectedProforma: selectedProforma ?? this.selectedProforma,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

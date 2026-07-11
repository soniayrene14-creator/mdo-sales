import '../../../domain/entities/proforma_entity.dart';

class ProformasState {
  final List<ProformaEntity>? proformas;
  final ProformaEntity? selectedProforma;
  final bool isLoading;

  const ProformasState({
    this.proformas,
    this.selectedProforma,
    this.isLoading = false,
  });

  ProformasState copyWith({
    List<ProformaEntity>? proformas,
    ProformaEntity? selectedProforma,
    bool? isLoading,
  }) {
    return ProformasState(
      proformas: proformas ?? this.proformas,
      selectedProforma: selectedProforma ?? this.selectedProforma,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

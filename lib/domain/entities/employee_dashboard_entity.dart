import 'package:equatable/equatable.dart';

class EmployeeDashboardEntity extends Equatable {
  final int nombreProduits;
  final int nombreCategories;
  final int mesVentesDuJour;
  final int monChiffreAffairesJour;
  final int mesProformas;

  const EmployeeDashboardEntity({
    required this.nombreProduits,
    required this.nombreCategories,
    required this.mesVentesDuJour,
    required this.monChiffreAffairesJour,
    required this.mesProformas,
  });

  @override
  List<Object?> get props => [nombreProduits, nombreCategories, mesVentesDuJour, monChiffreAffairesJour, mesProformas];
}

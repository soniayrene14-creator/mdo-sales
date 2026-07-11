import '../../domain/entities/employee_dashboard_entity.dart';

class EmployeeDashboardModel {
  int nombreProduits;
  int nombreCategories;
  int mesVentesDuJour;
  int monChiffreAffairesJour;
  int mesProformas;

  EmployeeDashboardModel({
    required this.nombreProduits,
    required this.nombreCategories,
    required this.mesVentesDuJour,
    required this.monChiffreAffairesJour,
    required this.mesProformas,
  });

  factory EmployeeDashboardModel.fromJson(Map<String, dynamic> json) {
    return EmployeeDashboardModel(
      nombreProduits: _toInt(json['nombre_produits']),
      nombreCategories: _toInt(json['nombre_categories']),
      mesVentesDuJour: _toInt(json['mes_ventes_du_jour']),
      monChiffreAffairesJour: _toInt(json['mon_chiffre_affaires_jour']),
      mesProformas: _toInt(json['mes_proformas']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre_produits': nombreProduits,
      'nombre_categories': nombreCategories,
      'mes_ventes_du_jour': mesVentesDuJour,
      'mon_chiffre_affaires_jour': monChiffreAffairesJour,
      'mes_proformas': mesProformas,
    };
  }

  factory EmployeeDashboardModel.fromEntity(EmployeeDashboardEntity entity) {
    return EmployeeDashboardModel(
      nombreProduits: entity.nombreProduits,
      nombreCategories: entity.nombreCategories,
      mesVentesDuJour: entity.mesVentesDuJour,
      monChiffreAffairesJour: entity.monChiffreAffairesJour,
      mesProformas: entity.mesProformas,
    );
  }

  EmployeeDashboardEntity toEntity() {
    return EmployeeDashboardEntity(
      nombreProduits: nombreProduits,
      nombreCategories: nombreCategories,
      mesVentesDuJour: mesVentesDuJour,
      monChiffreAffairesJour: monChiffreAffairesJour,
      mesProformas: mesProformas,
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return double.tryParse(value)?.toInt() ?? 0;
    return 0;
  }
}

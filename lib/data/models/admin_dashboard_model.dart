import '../../domain/entities/admin_dashboard_entity.dart';
import '../../domain/entities/employee_dashboard_entity.dart';
import '../../domain/entities/sales_report_entity.dart';

class AdminDashboardModel {
  int chiffreAffairesJour;
  int chiffreAffairesSemaine;
  int chiffreAffairesMois;
  int nombreProduits;
  int nombreEmployes;
  int produitsEnRupture;
  int produitsStockFaible;
  int nombreVentes;

  AdminDashboardModel({
    required this.chiffreAffairesJour,
    required this.chiffreAffairesSemaine,
    required this.chiffreAffairesMois,
    required this.nombreProduits,
    required this.nombreEmployes,
    required this.produitsEnRupture,
    required this.produitsStockFaible,
    required this.nombreVentes,
  });

  factory AdminDashboardModel.fromJson(Map<String, dynamic> json) {
    return AdminDashboardModel(
      chiffreAffairesJour: _toInt(json['chiffre_affaires_jour']),
      chiffreAffairesSemaine: _toInt(json['chiffre_affaires_semaine']),
      chiffreAffairesMois: _toInt(json['chiffre_affaires_mois']),
      nombreProduits: _toInt(json['nombre_produits']),
      nombreEmployes: _toInt(json['nombre_employes']),
      produitsEnRupture: _toInt(json['produits_en_rupture']),
      produitsStockFaible: _toInt(json['produits_stock_faible']),
      nombreVentes: _toInt(json['nombre_ventes']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chiffre_affaires_jour': chiffreAffairesJour,
      'chiffre_affaires_semaine': chiffreAffairesSemaine,
      'chiffre_affaires_mois': chiffreAffairesMois,
      'nombre_produits': nombreProduits,
      'nombre_employes': nombreEmployes,
      'produits_en_rupture': produitsEnRupture,
      'produits_stock_faible': produitsStockFaible,
      'nombre_ventes': nombreVentes,
    };
  }

  factory AdminDashboardModel.fromEntity(AdminDashboardEntity entity) {
    return AdminDashboardModel(
      chiffreAffairesJour: entity.chiffreAffairesJour,
      chiffreAffairesSemaine: entity.chiffreAffairesSemaine,
      chiffreAffairesMois: entity.chiffreAffairesMois,
      nombreProduits: entity.nombreProduits,
      nombreEmployes: entity.nombreEmployes,
      produitsEnRupture: entity.produitsEnRupture,
      produitsStockFaible: entity.produitsStockFaible,
      nombreVentes: entity.nombreVentes,
    );
  }

  AdminDashboardEntity toEntity() {
    return AdminDashboardEntity(
      chiffreAffairesJour: chiffreAffairesJour,
      chiffreAffairesSemaine: chiffreAffairesSemaine,
      chiffreAffairesMois: chiffreAffairesMois,
      nombreProduits: nombreProduits,
      nombreEmployes: nombreEmployes,
      produitsEnRupture: produitsEnRupture,
      produitsStockFaible: produitsStockFaible,
      nombreVentes: nombreVentes,
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

import '../../domain/entities/dashboard_entities.dart';

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
      chiffreAffairesJour: json['chiffreAffairesJour'] ??
          json['chiffre_affaires_jour'] ??
          0,
      chiffreAffairesSemaine: json['chiffreAffairesSemaine'] ??
          json['chiffre_affaires_semaine'] ??
          0,
      chiffreAffairesMois:
          json['chiffreAffairesMois'] ?? json['chiffre_affaires_mois'] ?? 0,
      nombreProduits: json['nombreProduits'] ?? json['nombre_produits'] ?? 0,
      nombreEmployes: json['nombreEmployes'] ?? json['nombre_employes'] ?? 0,
      produitsEnRupture:
          json['produitsEnRupture'] ?? json['produits_en_rupture'] ?? 0,
      produitsStockFaible:
          json['produitsStockFaible'] ?? json['produits_stock_faible'] ?? 0,
      nombreVentes: json['nombreVentes'] ?? json['nombre_ventes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chiffreAffairesJour': chiffreAffairesJour,
      'chiffre_affaires_jour': chiffreAffairesJour,
      'chiffreAffairesSemaine': chiffreAffairesSemaine,
      'chiffre_affaires_semaine': chiffreAffairesSemaine,
      'chiffreAffairesMois': chiffreAffairesMois,
      'chiffre_affaires_mois': chiffreAffairesMois,
      'nombreProduits': nombreProduits,
      'nombre_produits': nombreProduits,
      'nombreEmployes': nombreEmployes,
      'nombre_employes': nombreEmployes,
      'produitsEnRupture': produitsEnRupture,
      'produits_en_rupture': produitsEnRupture,
      'produitsStockFaible': produitsStockFaible,
      'produits_stock_faible': produitsStockFaible,
      'nombreVentes': nombreVentes,
      'nombre_ventes': nombreVentes,
    };
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
}

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
      nombreProduits: json['nombreProduits'] ?? json['nombre_produits'] ?? 0,
      nombreCategories:
          json['nombreCategories'] ?? json['nombre_categories'] ?? 0,
      mesVentesDuJour:
          json['mesVentesDuJour'] ?? json['mes_ventes_du_jour'] ?? 0,
      monChiffreAffairesJour: json['monChiffreAffairesJour'] ??
          json['mon_chiffre_affaires_jour'] ??
          0,
      mesProformas: json['mesProformas'] ?? json['mes_proformas'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombreProduits': nombreProduits,
      'nombre_produits': nombreProduits,
      'nombreCategories': nombreCategories,
      'nombre_categories': nombreCategories,
      'mesVentesDuJour': mesVentesDuJour,
      'mes_ventes_du_jour': mesVentesDuJour,
      'monChiffreAffairesJour': monChiffreAffairesJour,
      'mon_chiffre_affaires_jour': monChiffreAffairesJour,
      'mesProformas': mesProformas,
      'mes_proformas': mesProformas,
    };
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
}

class SalesReportModel {
  String periode;
  int nombreVentes;
  int chiffreAffairesTotal;
  List<Map<String, dynamic>> repartitionParPaiement;

  SalesReportModel({
    required this.periode,
    required this.nombreVentes,
    required this.chiffreAffairesTotal,
    required this.repartitionParPaiement,
  });

  factory SalesReportModel.fromJson(Map<String, dynamic> json) {
    final periodeValue = json['periode'];
    final periodeStr = periodeValue is String ? periodeValue : (periodeValue?.toString() ?? '');

    return SalesReportModel(
      periode: periodeStr,
      nombreVentes: json['nombreVentes'] ?? json['nombre_ventes'] ?? 0,
      chiffreAffairesTotal: json['chiffreAffairesTotal'] ??
          json['chiffre_affaires_total'] ??
          0,
      repartitionParPaiement: (json['repartitionParPaiement'] ??
              json['repartition_par_paiement'] as List<dynamic>? ??
              [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'periode': periode,
      'nombreVentes': nombreVentes,
      'nombre_ventes': nombreVentes,
      'chiffreAffairesTotal': chiffreAffairesTotal,
      'chiffre_affaires_total': chiffreAffairesTotal,
      'repartitionParPaiement': repartitionParPaiement,
      'repartition_par_paiement': repartitionParPaiement,
    };
  }

  SalesReportEntity toEntity() {
    return SalesReportEntity(
      periode: periode,
      nombreVentes: nombreVentes,
      chiffreAffairesTotal: chiffreAffairesTotal,
      repartitionParPaiement: repartitionParPaiement,
    );
  }
}

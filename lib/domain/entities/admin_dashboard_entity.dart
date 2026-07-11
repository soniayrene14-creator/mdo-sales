import 'package:equatable/equatable.dart';

class AdminDashboardEntity extends Equatable {
  final int chiffreAffairesJour;
  final int chiffreAffairesSemaine;
  final int chiffreAffairesMois;
  final int nombreProduits;
  final int nombreEmployes;
  final int produitsEnRupture;
  final int produitsStockFaible;
  final int nombreVentes;

  const AdminDashboardEntity({
    required this.chiffreAffairesJour,
    required this.chiffreAffairesSemaine,
    required this.chiffreAffairesMois,
    required this.nombreProduits,
    required this.nombreEmployes,
    required this.produitsEnRupture,
    required this.produitsStockFaible,
    required this.nombreVentes,
  });

  @override
  List<Object?> get props => [chiffreAffairesJour, chiffreAffairesSemaine, chiffreAffairesMois, nombreProduits, nombreEmployes, produitsEnRupture, produitsStockFaible, nombreVentes];
}

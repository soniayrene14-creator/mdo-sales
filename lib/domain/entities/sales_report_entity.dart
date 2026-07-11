import 'package:equatable/equatable.dart';

class SalesReportEntity extends Equatable {
  final String periode;
  final int nombreVentes;
  final int chiffreAffairesTotal;
  final List<Map<String, dynamic>> repartitionParPaiement;

  const SalesReportEntity({
    required this.periode,
    required this.nombreVentes,
    required this.chiffreAffairesTotal,
    required this.repartitionParPaiement,
  });

  @override
  List<Object?> get props => [periode, nombreVentes, chiffreAffairesTotal, repartitionParPaiement];
}

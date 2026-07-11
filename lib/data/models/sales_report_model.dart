import '../../domain/entities/sales_report_entity.dart';

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
    final repartition = json['repartition_par_paiement'];
    final list = repartition is List ? repartition.cast<Map<String, dynamic>>() : <Map<String, dynamic>>[];

    return SalesReportModel(
      periode: json['periode'] ?? '',
      nombreVentes: _toInt(json['nombre_ventes']),
      chiffreAffairesTotal: _toInt(json['chiffre_affaires_total']),
      repartitionParPaiement: list,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'periode': periode,
      'nombre_ventes': nombreVentes,
      'chiffre_affaires_total': chiffreAffairesTotal,
      'repartition_par_paiement': repartitionParPaiement,
    };
  }

  factory SalesReportModel.fromEntity(SalesReportEntity entity) {
    return SalesReportModel(
      periode: entity.periode,
      nombreVentes: entity.nombreVentes,
      chiffreAffairesTotal: entity.chiffreAffairesTotal,
      repartitionParPaiement: entity.repartitionParPaiement,
    );
  }

  SalesReportEntity toEntity() {
    return SalesReportEntity(
      periode: periode,
      nombreVentes: nombreVentes,
      chiffreAffairesTotal: chiffreAffairesTotal,
      repartitionParPaiement: repartitionParPaiement,
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

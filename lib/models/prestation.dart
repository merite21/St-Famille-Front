import '../services/json_helpers.dart';

class Prestation {
  final int id;
  final String code;
  final String libelle;
  final double montantFcfa;

  const Prestation({
    required this.id,
    required this.code,
    required this.libelle,
    required this.montantFcfa,
  });

  factory Prestation.fromJson(Map<String, dynamic> json) {
    return Prestation(
      id: parseApiInt(json['id'])!,
      code: json['code'] as String,
      libelle: json['libelle'] as String,
      montantFcfa: parseApiDouble(json['montant_fcfa']) ?? 0,
    );
  }
}

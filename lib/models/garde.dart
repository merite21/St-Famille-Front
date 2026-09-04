import '../services/json_helpers.dart';

class Garde {
  final int id;
  final int userId;
  final DateTime dateGarde;
  final String typeGarde; // jour, nuit, 24h
  final String statut; // planifiee, confirmee, remplacee, annulee
  final int? remplacePar;
  final String? userNom;

  const Garde({
    required this.id,
    required this.userId,
    required this.dateGarde,
    required this.typeGarde,
    required this.statut,
    this.remplacePar,
    this.userNom,
  });

  factory Garde.fromJson(Map<String, dynamic> json) {
    return Garde(
      id: parseApiInt(json['id'])!,
      userId: parseApiInt(json['user_id'])!,
      dateGarde: parseApiDate(json['date_garde'])!,
      typeGarde: json['type_garde'] as String,
      statut: json['statut'] as String,
      remplacePar: parseApiInt(json['remplace_par']),
      userNom: json['user_nom'] as String?,
    );
  }
}

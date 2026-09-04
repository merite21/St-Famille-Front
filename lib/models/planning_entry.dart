import '../services/json_helpers.dart';

class PlanningEntry {
  final int id;
  final int userId;
  final DateTime dateDebut;
  final DateTime dateFin;
  final String? service;
  final String? userNom;

  const PlanningEntry({
    required this.id,
    required this.userId,
    required this.dateDebut,
    required this.dateFin,
    this.service,
    this.userNom,
  });

  factory PlanningEntry.fromJson(Map<String, dynamic> json) {
    return PlanningEntry(
      id: parseApiInt(json['id'])!,
      userId: parseApiInt(json['user_id'])!,
      dateDebut: parseApiDate(json['date_debut'])!,
      dateFin: parseApiDate(json['date_fin'])!,
      service: json['service'] as String?,
      userNom: json['user_nom'] as String?,
    );
  }
}

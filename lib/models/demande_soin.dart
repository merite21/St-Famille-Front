import '../services/json_helpers.dart';

class DemandeSoin {
  final int id;
  final int dossierId;
  final String priorite; // normale, urgente
  final String? instructions;
  final String statut;
  final DateTime createdAt;

  /// Fournis uniquement par GET /demandes-soins (jointures), absents
  /// de la réponse brute de création.
  final String? typeSoin;
  final String? patientNom;
  final String? numeroDossier;
  final String? medecinNom;
  final int? attributionId;

  const DemandeSoin({
    required this.id,
    required this.dossierId,
    required this.priorite,
    required this.statut,
    required this.createdAt,
    this.instructions,
    this.typeSoin,
    this.patientNom,
    this.numeroDossier,
    this.medecinNom,
    this.attributionId,
  });

  factory DemandeSoin.fromJson(Map<String, dynamic> json) {
    return DemandeSoin(
      id: parseApiInt(json['id'])!,
      dossierId: parseApiInt(json['dossier_id'])!,
      priorite: json['priorite'] as String,
      statut: json['statut'] as String,
      createdAt: parseApiDate(json['created_at'])!,
      instructions: json['instructions'] as String?,
      typeSoin: json['type_soin'] as String?,
      patientNom: json['patient_nom'] as String?,
      numeroDossier: json['numero_dossier'] as String?,
      medecinNom: json['medecin_nom'] as String?,
      attributionId: parseApiInt(json['attribution_id']),
    );
  }
}

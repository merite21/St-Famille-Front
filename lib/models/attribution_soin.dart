import '../services/json_helpers.dart';

class AttributionSoin {
  final int id;
  final String statut;
  final DateTime attribueAt;
  final int? salleSoinId;
  final String? salleNom;
  final String priorite;
  final String? instructions;
  final String typeSoin;
  final String patientNom;
  final String numeroDossier;
  final String medecinNom;
  final int? soinId;

  const AttributionSoin({
    required this.id,
    required this.statut,
    required this.attribueAt,
    required this.priorite,
    required this.typeSoin,
    required this.patientNom,
    required this.numeroDossier,
    required this.medecinNom,
    this.salleSoinId,
    this.salleNom,
    this.instructions,
    this.soinId,
  });

  factory AttributionSoin.fromJson(Map<String, dynamic> json) {
    return AttributionSoin(
      id: parseApiInt(json['id'])!,
      statut: json['statut'] as String,
      attribueAt: parseApiDate(json['attribue_at'])!,
      salleSoinId: parseApiInt(json['salle_soin_id']),
      salleNom: json['salle_nom'] as String?,
      priorite: json['priorite'] as String,
      instructions: json['instructions'] as String?,
      typeSoin: json['type_soin'] as String,
      patientNom: json['patient_nom'] as String,
      numeroDossier: json['numero_dossier'] as String,
      medecinNom: json['medecin_nom'] as String,
      soinId: parseApiInt(json['soin_id']),
    );
  }
}

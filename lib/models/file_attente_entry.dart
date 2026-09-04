import '../services/json_helpers.dart';

class FileAttenteEntry {
  final int id;
  final int dossierId;
  final int? medecinId;
  final String priorite; // normale, urgente
  final String statut; // en_attente, appele, en_consultation, termine, annule
  final DateTime entreeAt;
  final DateTime? appeleAt;
  final DateTime? termineAt;

  /// Fourni uniquement par GET /file-attente (jointure), absent des
  /// réponses de création/mise à jour.
  final String? patientNom;

  const FileAttenteEntry({
    required this.id,
    required this.dossierId,
    required this.priorite,
    required this.statut,
    required this.entreeAt,
    this.medecinId,
    this.appeleAt,
    this.termineAt,
    this.patientNom,
  });

  factory FileAttenteEntry.fromJson(Map<String, dynamic> json) {
    return FileAttenteEntry(
      id: parseApiInt(json['id'])!,
      dossierId: parseApiInt(json['dossier_id'])!,
      medecinId: parseApiInt(json['medecin_id']),
      priorite: json['priorite'] as String,
      statut: json['statut'] as String,
      entreeAt: parseApiDate(json['entree_at'])!,
      appeleAt: parseApiDate(json['appele_at']),
      termineAt: parseApiDate(json['termine_at']),
      patientNom: json['patient_nom'] as String?,
    );
  }
}

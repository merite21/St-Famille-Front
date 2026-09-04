import '../services/json_helpers.dart';
import 'patient.dart';

class Dossier {
  final int id;
  final String statut; // ouvert, en_cours, cloture
  final String? motif;
  final DateTime ouvertAt;
  final DateTime? clotureAt;
  final Patient patient;

  const Dossier({
    required this.id,
    required this.statut,
    required this.ouvertAt,
    required this.patient,
    this.motif,
    this.clotureAt,
  });

  /// Le contrôleur back-end renvoie soit un objet "patient" imbriqué
  /// (POST /dossiers, GET /dossiers/{id}), soit les champs du patient à
  /// plat (GET /dossiers?patient_id=...) : on gère les deux formes.
  factory Dossier.fromJson(Map<String, dynamic> json) {
    final Patient patient;
    if (json['patient'] is Map) {
      patient = Patient.fromJson(Map<String, dynamic>.from(json['patient'] as Map));
    } else {
      patient = Patient(
        id: parseApiInt(json['patient_id'])!,
        numeroDossier: json['numero_dossier'] as String,
        nom: json['nom'] as String,
        prenom: json['prenom'] as String,
      );
    }

    return Dossier(
      id: parseApiInt(json['id'])!,
      statut: json['statut'] as String,
      motif: json['motif'] as String?,
      ouvertAt: parseApiDate(json['ouvert_at'])!,
      clotureAt: parseApiDate(json['cloture_at']),
      patient: patient,
    );
  }
}

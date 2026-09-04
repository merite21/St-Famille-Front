import '../services/json_helpers.dart';

class Paiement {
  final int id;
  final int dossierId;
  final int prestationId;
  final double montantFcfa;
  final String statut; // en_attente, confirme, annule, rembourse
  final String? referenceExterne;
  final DateTime demandeAt;
  final DateTime? confirmeAt;

  /// Fournis uniquement par GET /paiements (jointures), absents des
  /// réponses de création/confirmation.
  final String? patientNom;
  final String? numeroDossier;
  final String? prestationLibelle;

  const Paiement({
    required this.id,
    required this.dossierId,
    required this.prestationId,
    required this.montantFcfa,
    required this.statut,
    required this.demandeAt,
    this.referenceExterne,
    this.confirmeAt,
    this.patientNom,
    this.numeroDossier,
    this.prestationLibelle,
  });

  factory Paiement.fromJson(Map<String, dynamic> json) {
    return Paiement(
      id: parseApiInt(json['id'])!,
      dossierId: parseApiInt(json['dossier_id'])!,
      prestationId: parseApiInt(json['prestation_id'])!,
      montantFcfa: parseApiDouble(json['montant_fcfa']) ?? 0,
      statut: json['statut'] as String,
      referenceExterne: json['reference_externe'] as String?,
      demandeAt: parseApiDate(json['demande_at'])!,
      confirmeAt: parseApiDate(json['confirme_at']),
      patientNom: json['patient_nom'] as String?,
      numeroDossier: json['numero_dossier'] as String?,
      prestationLibelle: json['prestation_libelle'] as String?,
    );
  }
}

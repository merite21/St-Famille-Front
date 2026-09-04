import '../services/json_helpers.dart';

class Consultation {
  final int id;
  final int dossierId;
  final int medecinId;
  final String? motif;
  final String? observations;
  final String? diagnostic;
  final String orientation; // sans_soins, avec_soins, autre
  final DateTime debutAt;
  final DateTime? finAt;

  const Consultation({
    required this.id,
    required this.dossierId,
    required this.medecinId,
    required this.orientation,
    required this.debutAt,
    this.motif,
    this.observations,
    this.diagnostic,
    this.finAt,
  });

  factory Consultation.fromJson(Map<String, dynamic> json) {
    return Consultation(
      id: parseApiInt(json['id'])!,
      dossierId: parseApiInt(json['dossier_id'])!,
      medecinId: parseApiInt(json['medecin_id'])!,
      motif: json['motif'] as String?,
      observations: json['observations'] as String?,
      diagnostic: json['diagnostic'] as String?,
      orientation: json['orientation'] as String,
      debutAt: parseApiDate(json['debut_at'])!,
      finAt: parseApiDate(json['fin_at']),
    );
  }
}

import '../services/json_helpers.dart';

class Soin {
  final int id;
  final int attributionId;
  final DateTime? heureSoin;
  final String? soinRealise;
  final String? observations;
  final String? incident;
  final String? commentaire;
  final bool valide;
  final DateTime? valideAt;

  const Soin({
    required this.id,
    required this.attributionId,
    this.heureSoin,
    this.soinRealise,
    this.observations,
    this.incident,
    this.commentaire,
    this.valide = false,
    this.valideAt,
  });

  factory Soin.fromJson(Map<String, dynamic> json) {
    return Soin(
      id: parseApiInt(json['id'])!,
      attributionId: parseApiInt(json['attribution_id'])!,
      heureSoin: parseApiDate(json['heure_soin']),
      soinRealise: json['soin_realise'] as String?,
      observations: json['observations'] as String?,
      incident: json['incident'] as String?,
      commentaire: json['commentaire'] as String?,
      valide: parseApiBool(json['valide']),
      valideAt: parseApiDate(json['valide_at']),
    );
  }
}

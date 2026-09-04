import '../services/json_helpers.dart';

class Constantes {
  final int id;
  final int dossierId;
  final double? temperature;
  final int? tensionSystolique;
  final int? tensionDiastolique;
  final int? pouls;
  final double? poids;
  final double? taille;
  final int? saturationO2;
  final DateTime createdAt;

  const Constantes({
    required this.id,
    required this.dossierId,
    required this.createdAt,
    this.temperature,
    this.tensionSystolique,
    this.tensionDiastolique,
    this.pouls,
    this.poids,
    this.taille,
    this.saturationO2,
  });

  factory Constantes.fromJson(Map<String, dynamic> json) {
    return Constantes(
      id: parseApiInt(json['id'])!,
      dossierId: parseApiInt(json['dossier_id'])!,
      createdAt: parseApiDate(json['created_at'])!,
      temperature: parseApiDouble(json['temperature']),
      tensionSystolique: parseApiInt(json['tension_systolique']),
      tensionDiastolique: parseApiInt(json['tension_diastolique']),
      pouls: parseApiInt(json['pouls']),
      poids: parseApiDouble(json['poids']),
      taille: parseApiDouble(json['taille']),
      saturationO2: parseApiInt(json['saturation_o2']),
    );
  }
}

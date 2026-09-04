import '../services/json_helpers.dart';

class SalleSoin {
  final int id;
  final String nom;
  final bool disponible;

  const SalleSoin({
    required this.id,
    required this.nom,
    this.disponible = true,
  });

  factory SalleSoin.fromJson(Map<String, dynamic> json) {
    return SalleSoin(
      id: parseApiInt(json['id'])!,
      nom: json['nom'] as String,
      disponible: parseApiBool(json['disponible']),
    );
  }
}

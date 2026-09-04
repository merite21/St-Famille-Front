import '../services/json_helpers.dart';

class Utilisateur {
  final int id;
  final String matricule;
  final String nom;
  final String prenom;
  final String? email;
  final String? telephone;
  final bool actif;
  final String role;

  const Utilisateur({
    required this.id,
    required this.matricule,
    required this.nom,
    required this.prenom,
    required this.role,
    this.email,
    this.telephone,
    this.actif = true,
  });

  factory Utilisateur.fromJson(Map<String, dynamic> json) {
    return Utilisateur(
      id: parseApiInt(json['id'])!,
      matricule: json['matricule'] as String,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      role: json['role'] as String,
      email: json['email'] as String?,
      telephone: json['telephone'] as String?,
      actif: json.containsKey('actif')
          ? (json['actif'] == 1 || json['actif'] == true)
          : true,
    );
  }

  String get nomComplet => '$nom $prenom';
}

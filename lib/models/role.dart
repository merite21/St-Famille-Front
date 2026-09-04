import '../services/json_helpers.dart';

class Role {
  final int id;
  final String nom;
  final String? description;

  const Role({required this.id, required this.nom, this.description});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: parseApiInt(json['id'])!,
      nom: json['nom'] as String,
      description: json['description'] as String?,
    );
  }

  /// Libellé lisible pour l'affichage (le back-end stocke des noms de
  /// rôle en snake_case, ex. "infirmier_responsable").
  String get libelle => roleLabel(nom);
}

/// Libellé français pour un nom de rôle brut renvoyé par l'API
/// (snake_case, ex. "infirmier_responsable"), sans avoir besoin d'une
/// instance de [Role] complète.
String roleLabel(String role) {
  switch (role) {
    case 'administrateur':
      return 'Administrateur';
    case 'receptionniste':
      return 'Réceptionniste';
    case 'caissier':
      return 'Caissier(ère)';
    case 'medecin':
      return 'Médecin';
    case 'infirmier_responsable':
      return 'Infirmier(ère) responsable';
    case 'infirmier':
      return 'Infirmier(ère)';
    default:
      return role;
  }
}

import '../services/json_helpers.dart';

class Patient {
  final int id;
  final String numeroDossier;
  final String nom;
  final String prenom;
  final DateTime? dateNaissance;
  final String? sexe; // 'M' ou 'F'
  final String? telephone;
  final String? adresse;
  final String? contactUrgence;

  const Patient({
    required this.id,
    required this.numeroDossier,
    required this.nom,
    required this.prenom,
    this.dateNaissance,
    this.sexe,
    this.telephone,
    this.adresse,
    this.contactUrgence,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: parseApiInt(json['id'])!,
      numeroDossier: json['numero_dossier'] as String,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      dateNaissance: parseApiDate(json['date_naissance']),
      sexe: json['sexe'] as String?,
      telephone: json['telephone'] as String?,
      adresse: json['adresse'] as String?,
      contactUrgence: json['contact_urgence'] as String?,
    );
  }

  String get sexeLabel {
    switch (sexe) {
      case 'M':
        return 'Homme';
      case 'F':
        return 'Femme';
      default:
        return 'Non renseigné';
    }
  }

  int? get age {
    final naissance = dateNaissance;
    if (naissance == null) return null;

    final now = DateTime.now();
    int age = now.year - naissance.year;
    if (now.month < naissance.month ||
        (now.month == naissance.month && now.day < naissance.day)) {
      age--;
    }
    return age;
  }

  String get nomComplet => '$nom $prenom';
}

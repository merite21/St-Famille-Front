class Patient {
  final String id;
  final String nom;
  final String prenom;
  final String sexe;
  final int age;
  final String telephone;
  final String statut;

  const Patient({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.sexe,
    required this.age,
    required this.telephone,
    required this.statut,
  });
}
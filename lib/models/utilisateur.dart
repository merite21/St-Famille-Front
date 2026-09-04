class Utilisateur {
  final String id;
  final String nom;
  final String prenom;
  final String role;
  final String email;
  final String telephone;
  final String statut;

  const Utilisateur({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.role,
    required this.email,
    required this.telephone,
    required this.statut,
  });
}

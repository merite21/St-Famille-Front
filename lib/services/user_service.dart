import '../models/utilisateur.dart';
import 'api_client.dart';

class UserService {
  UserService._();
  static final UserService instance = UserService._();

  Future<List<Utilisateur>> list() async {
    final data = await ApiClient.instance.get('/users');
    return (data as List)
        .map((item) => Utilisateur.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<Utilisateur> create({
    required String matricule,
    required String nom,
    required String prenom,
    required int roleId,
    required String password,
    String? email,
    String? telephone,
  }) async {
    final data = await ApiClient.instance.post('/users', {
      'matricule': matricule,
      'nom': nom,
      'prenom': prenom,
      'role_id': roleId,
      'password': password,
      if (email != null && email.isNotEmpty) 'email': email,
      if (telephone != null && telephone.isNotEmpty) 'telephone': telephone,
    });
    return Utilisateur.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<Utilisateur> update(
    int id, {
    String? nom,
    String? prenom,
    String? email,
    String? telephone,
    int? roleId,
    bool? actif,
  }) async {
    final data = await ApiClient.instance.put('/users/$id', {
      if (nom != null) 'nom': nom,
      if (prenom != null) 'prenom': prenom,
      if (email != null) 'email': email,
      if (telephone != null) 'telephone': telephone,
      if (roleId != null) 'role_id': roleId,
      if (actif != null) 'actif': actif,
    });
    return Utilisateur.fromJson(Map<String, dynamic>.from(data as Map));
  }
}

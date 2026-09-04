import '../models/utilisateur.dart';
import 'api_client.dart';

/// Session applicative : token JWT courant + utilisateur connecté.
///
/// Le token n'est conservé qu'en mémoire (pas de stockage persistant) :
/// une reconnexion est nécessaire à chaque redémarrage de l'application.
class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  Utilisateur? _currentUser;

  Utilisateur? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Future<Utilisateur> login(String matricule, String password) async {
    final data = await ApiClient.instance.post('/auth/login', {
      'matricule': matricule,
      'password': password,
    });

    final token = data['access_token'] as String;
    ApiClient.instance.setToken(token);

    _currentUser = Utilisateur.fromJson(
      Map<String, dynamic>.from(data['user'] as Map),
    );

    return _currentUser!;
  }

  void logout() {
    _currentUser = null;
    ApiClient.instance.setToken(null);
  }
}

/// Configuration de connexion à l'API REST PHP.
///
/// Par défaut, pointe vers le backend Slim servi en local via XAMPP
/// (dossier `Sainte_Famille` dans `htdocs`), pour coller au guide de
/// démarrage du backend. Pour un déploiement réel, surcharge l'URL au
/// moment du build, sans toucher au code :
///
///   flutter run --dart-define=API_BASE_URL=https://api.saintefamille.example.com/v1
///   flutter build web --dart-define=API_BASE_URL=https://api.saintefamille.example.com/v1
class ApiConfig {
  const ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost/Sainte_Famille/public/v1',
  );
}

# Sainte Famille - Front

Application Flutter de gestion hospitalière pour le centre Sainte Famille :
connexion du personnel, tableau de bord, et l'ensemble des modules du
parcours patient (accueil, file d'attente, consultations, soins,
paiements, planning et administration).

Le front est **intégré à l'API REST PHP réelle** — voir le dépôt backend
[`Sainte_Famille`](https://github.com/merite21/Sainte_Famille) (Slim 4 +
JWT + MySQL). Il n'y a plus de données simulées : chaque écran lit et
écrit dans la base via l'API.

## Fonctionnalités

- **Connexion** : authentification par matricule / mot de passe (JWT).
- **Tableau de bord** : statistiques en direct (patients, file d'attente,
  demandes de soins), notifications, accès rapides.
- **Patients** : recherche, création et consultation des dossiers patients,
  historique des dossiers de prise en charge.
- **Réception** : recherche ou création d'un patient, ouverture d'un
  dossier de prise en charge, saisie des constantes.
- **Paiements** : création d'un paiement (dossier + prestation),
  confirmation, envoi en file d'attente.
- **File d'attente** : suivi en direct, appel du patient (avec
  affectation d'un médecin), passage en consultation puis clôture.
- **Consultations** : création depuis la file d'attente, orientation
  avec ou sans soins, déclenchement d'une demande de soins infirmiers.
- **Soins infirmiers** : attribution d'une demande à un infirmier et une
  salle, démarrage, réalisation et validation du soin.
- **Planning** : plannings de service et gardes du personnel.
- **Administration** : gestion des comptes et rôles du personnel.

## Architecture

- `lib/config/api_config.dart` : URL de base de l'API (surchargeable au
  build, voir plus bas).
- `lib/services/api_client.dart` : client HTTP générique (authentification,
  JSON, gestion d'erreurs) utilisé par tous les autres services.
- `lib/services/<ressource>_service.dart` : un service par ressource de
  l'API (patients, dossiers, paiements, file d'attente, consultations,
  soins, planning, gardes, utilisateurs, rôles, notifications...).
- `lib/models/` : entités du domaine, alignées sur les réponses JSON de
  l'API (`fromJson` tolérant aux champs optionnels/imbriqués).
- `lib/widgets/` : composants d'interface réutilisés par tous les modules
  (en-tête d'écran, cartes de statistiques, badges de statut).
- `lib/screens/<module>/` : un dossier par module métier.

## Configuration de l'API

Par défaut, l'application pointe vers un backend servi en local via XAMPP :

```
http://localhost/Sainte_Famille/public/v1
```

Pour cibler un autre environnement (recette, production...), surcharge
l'URL au moment du build ou du lancement, sans toucher au code :

```bash
flutter run --dart-define=API_BASE_URL=https://api.saintefamille.example.com/v1
flutter build web --dart-define=API_BASE_URL=https://api.saintefamille.example.com/v1
flutter build apk --dart-define=API_BASE_URL=https://api.saintefamille.example.com/v1
```

## Démarrage

```bash
flutter pub get
flutter run
```

Un backend fonctionnel (voir le dépôt `Sainte_Famille`) doit être
accessible à l'URL configurée pour que l'application fonctionne : elle
ne contient plus de mode démo hors-ligne.

## Tests

```bash
flutter test
```

## Déploiement

- **Web** : `flutter build web --dart-define=API_BASE_URL=...` puis héberge
  le contenu de `build/web/` sur n'importe quel hébergeur statique (le
  backend doit autoriser l'origine via `CORS_ALLOW_ORIGIN` côté PHP).
- **Mobile (Android/iOS)** : `flutter build apk` / `flutter build ipa` avec
  le même `--dart-define`.
- **Desktop (Windows/macOS/Linux)** : `flutter build windows` / `macos` / `linux`.

## Ressources Flutter

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

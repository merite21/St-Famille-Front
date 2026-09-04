# Sainte Famille - Front

Application Flutter de gestion hospitalière pour le centre Sainte Famille :
connexion du personnel, tableau de bord, gestion des dossiers patients
(création, recherche, consultation) et suivi du parcours de soins.

## Fonctionnalités actuelles

- **Connexion** : écran d'authentification du personnel (identifiant / mot de passe).
- **Tableau de bord** : vue d'ensemble de l'activité de l'établissement (statistiques,
  file d'attente, accès rapides).
- **Patients** : liste, recherche et création de dossiers patients.
- **Dossier patient** : informations administratives, personne à contacter,
  informations médicales et historique des prises en charge.

L'authentification et la persistance des données sont pour l'instant simulées
côté client ; elles seront connectées à une API REST PHP dans une itération
ultérieure.

## Démarrage

```bash
flutter pub get
flutter run
```

## Tests

```bash
flutter test
```

## Ressources Flutter

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

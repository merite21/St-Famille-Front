# Sainte Famille - Front

Application Flutter de gestion hospitalière pour le centre Sainte Famille :
connexion du personnel, tableau de bord, et l'ensemble des modules du
parcours patient (accueil, file d'attente, consultations, soins,
paiements, planning et administration).

## Fonctionnalités actuelles

- **Connexion** : écran d'authentification du personnel (identifiant / mot de passe).
- **Tableau de bord** : vue d'ensemble de l'activité de l'établissement (statistiques,
  file d'attente en direct, accès rapides vers les modules).
- **Patients** : liste, recherche, création et consultation des dossiers patients
  (informations administratives, contact d'urgence, informations médicales,
  historique des prises en charge).
- **Réception** : enregistrement de l'arrivée d'un patient et orientation vers
  un service.
- **File d'attente** : suivi en direct des patients enregistrés à la réception,
  avec progression de leur statut (En attente → En consultation → Terminé).
- **Consultations** : planification et suivi des consultations médicales.
- **Soins infirmiers** : planification et suivi des soins réalisés.
- **Paiements** : enregistrement et historique des paiements des patients.
- **Planning** : planification des rendez-vous patients / médecins.
- **Administration** : gestion des comptes et rôles du personnel.

## Architecture

- `lib/models/` : entités du domaine (Patient, PriseEnCharge, Paiement,
  Consultation, SoinInfirmier, RendezVous, Utilisateur).
- `lib/data/` : dépôts en mémoire partagés entre écrans (ex. `PatientDirectory`,
  `QueueDirectory`), qui centralisent les données de démonstration.
- `lib/widgets/` : composants d'interface réutilisés par tous les modules
  (en-tête d'écran, cartes de statistiques, badges de statut).
- `lib/screens/<module>/` : un dossier par module métier.

L'authentification et la persistance des données sont pour l'instant simulées
côté client (délai simulé + stockage en mémoire), avec des commentaires
`// Simulation temporaire ... sera remplacée par l'appel à l'API REST PHP`
à chaque point d'intégration. Ces points sont les emplacements exacts où
brancher les appels à l'API REST PHP lors de l'intégration back-end.

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

# Backend Hôpital Sainte Famille — Guide de démarrage

Ce projet utilise **Slim 4** (un micro-framework PHP léger, parfait pour une API REST).
Suis les étapes dans l'ordre, une seule fois pour l'installation.

## 0. Pré-requis

- XAMPP déjà installé (tu l'as ✅)
- **Composer** : le gestionnaire de dépendances de PHP (l'équivalent de `pub` pour Flutter/Dart).
  Si tu ne l'as pas : télécharge-le sur https://getcomposer.org/download/ et installe-le.
  Vérifie avec : `composer --version` dans un terminal.

## 1. Placer le projet dans XAMPP

Copie tout le dossier `sainte-famille-backend/` dans le dossier `htdocs` de XAMPP :

- Windows : `C:\xampp\htdocs\sainte-famille-backend`
- Mac : `/Applications/XAMPP/htdocs/sainte-famille-backend`

## 2. Installer les dépendances PHP

Ouvre un terminal **dans le dossier du projet** et lance :

```bash
composer install
```

Ça va créer un dossier `vendor/` avec Slim, le JWT, etc. (ce dossier ne doit PAS être
envoyé sur GitHub — je t'ai mis un `.gitignore` pour ça).

## 3. Créer la base de données

1. Démarre **Apache** et **MySQL** dans le panneau de contrôle XAMPP.
2. Va sur `http://localhost/phpmyadmin`
3. Crée une base nommée exactement `sainte_famille`
4. Onglet "Importer" → choisis le fichier `schema.sql` (celui qu'on a généré avant) → Exécuter

## 4. Configurer les variables d'environnement

Duplique `.env.example` en `.env` (même dossier), et vérifie les valeurs :

```
DB_HOST=127.0.0.1
DB_NAME=sainte_famille
DB_USER=root
DB_PASS=
```

Par défaut, XAMPP utilise l'utilisateur `root` sans mot de passe. Change `JWT_SECRET`
par n'importe quelle longue chaîne de caractères.

## 5. Créer un premier utilisateur de test

Le fichier `schema.sql` crée les rôles mais pas d'utilisateur. Dans phpMyAdmin,
onglet "SQL" de ta base, exécute (mot de passe = `test1234`) :

```sql
INSERT INTO users (role_id, matricule, nom, prenom, password_hash, actif)
VALUES (
  (SELECT id FROM roles WHERE nom = 'administrateur'),
  'ADM-001', 'Doe', 'Jane',
  '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', -- = "test1234"
  1
);
```

## 6. Lancer et tester

Ouvre dans le navigateur : `http://localhost/sainte-famille-backend/public/`
(tu devrais voir une erreur "Not Found" — c'est normal, il n'y a pas de route sur `/`).

Teste la connexion avec **Postman** ou **Insomnia** (logiciels gratuits) :

```
POST http://localhost/sainte-famille-backend/public/v1/auth/login
Content-Type: application/json

{
  "matricule": "ADM-001",
  "password": "test1234"
}
```

Tu dois recevoir un JSON avec un `access_token`. Copie ce token, puis teste une route
protégée :

```
GET http://localhost/sainte-famille-backend/public/v1/patients
Authorization: Bearer <colle le token ici>
```

Tu devrais recevoir `{"data": [], "meta": {...}}` (vide, car aucun patient encore).

Essaie ensuite de créer un patient :

```
POST http://localhost/sainte-famille-backend/public/v1/patients
Authorization: Bearer <token>
Content-Type: application/json

{
  "nom": "Kponou",
  "prenom": "Marie",
  "sexe": "F",
  "telephone": "0197000000"
}
```

## 7. Et maintenant ?

Le contrôleur `PatientController.php` est ton **modèle**. Pour chaque nouvelle
ressource du contrat API (`api-contract.yaml`) :

1. Crée un fichier dans `src/Controllers/`, ex: `DossierController.php`
2. Copie la structure de `PatientController` (list / show / create / update)
3. Adapte les requêtes SQL à la bonne table (`schema.sql`)
4. Ajoute les routes correspondantes dans `public/index.php`, dans le groupe `/v1`

Ordre conseillé (suit le parcours patient) :
`Dossiers` → `Constantes` → `Paiements` → `FileAttente` → `Consultations` →
`SoinsInfirmiers` (3 contrôleurs: DemandeSoin, AttributionSoin, Soin) →
`Plannings` / `Gardes` → `Administration` (Users) → `Notifications`

## Structure du projet

```
sainte-famille-backend/
├── composer.json          # dépendances PHP
├── .env.example            # variables d'environnement (à copier en .env)
├── public/
│   ├── index.php           # point d'entrée + définition des routes
│   └── .htaccess           # redirige tout vers index.php
└── src/
    ├── Database.php               # connexion MySQL (PDO)
    ├── Http/JsonResponse.php      # helper pour répondre en JSON
    ├── Middleware/JwtMiddleware.php  # vérifie le token sur les routes protégées
    └── Controllers/
        ├── AuthController.php     # login
        └── PatientController.php  # exemple complet CRUD à dupliquer
```

<?php

require __DIR__ . '/../vendor/autoload.php';

use App\Controllers\AuthController;
use App\Controllers\PatientController;
use App\Controllers\DossierController;
use App\Controllers\ConstantesController;
use App\Controllers\PrestationController;
use App\Controllers\PaiementController;
use App\Controllers\FileAttenteController;
use App\Controllers\ConsultationController;
use App\Controllers\DemandeSoinController;
use App\Controllers\AttributionSoinController;
use App\Controllers\SoinController;
use App\Controllers\SalleSoinController;
use App\Controllers\TypeSoinController;
use App\Controllers\PlanningController;
use App\Controllers\GardeController;
use App\Controllers\RoleController;
use App\Controllers\UserController;
use App\Controllers\NotificationController;
use App\Middleware\JwtMiddleware;
use Slim\Factory\AppFactory;

// Charge les variables du fichier .env dans $_ENV
$dotenv = Dotenv\Dotenv::createImmutable(__DIR__ . '/..');
$dotenv->load();

$app = AppFactory::create();

// Sur un hébergement classique, public/ est directement la racine web :
// aucun préfixe n'est nécessaire (APP_BASE_PATH vide, comportement par
// défaut). Ne renseigne APP_BASE_PATH que si l'API est servie depuis un
// sous-dossier (ex. XAMPP : /Sainte_Famille/public).
$basePath = $_ENV['APP_BASE_PATH'] ?? '';
if ($basePath !== '') {
    $app->setBasePath($basePath);
}

$debug = filter_var($_ENV['APP_DEBUG'] ?? 'false', FILTER_VALIDATE_BOOLEAN);

$app->addBodyParsingMiddleware();
$app->addErrorMiddleware($debug, $debug, $debug);

// Permet à Flutter (autre origine) d'appeler l'API depuis le navigateur/l'appli.
// Ajoutée en DERNIER (donc la plus extérieure de la pile) pour que les en-têtes
// CORS soient présents même sur les réponses d'erreur (404, 500...) : sinon le
// navigateur bloque la réponse d'erreur elle-même avant qu'elle n'atteigne le
// code JS/Flutter, masquant le vrai message d'erreur derrière une erreur CORS.
$app->add(function ($request, $handler) {
    $response = $handler->handle($request);
    return $response
        ->withHeader('Access-Control-Allow-Origin', $_ENV['CORS_ALLOW_ORIGIN'] ?? '*')
        ->withHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization')
        ->withHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
});

// Répond directement aux requêtes de pré-vérification CORS (preflight) que le
// navigateur envoie avant tout POST/PUT avec un corps JSON ou un header
// Authorization, pour toutes les routes — sans cette route, ces OPTIONS
// tombaient en 404 avant même d'atteindre le middleware CORS ci-dessus.
$app->options('/{routes:.+}', function ($request, $response) {
    return $response;
});

// ---------------------------------------------------------------
// Routes PUBLIQUES (pas besoin d'être connecté)
// ---------------------------------------------------------------
$app->post('/v1/auth/login', [AuthController::class, 'login']);

// ---------------------------------------------------------------
// Routes PROTÉGÉES (nécessitent un token JWT valide)
// Le groupe applique JwtMiddleware à toutes les routes qu'il contient.
// ---------------------------------------------------------------
$app->group('/v1', function ($group) {

    // --- Patients ---
    $group->get('/patients', [PatientController::class, 'list']);
    $group->post('/patients', [PatientController::class, 'create']);
    $group->get('/patients/{id}', [PatientController::class, 'show']);
    $group->put('/patients/{id}', [PatientController::class, 'update']);

    // --- Dossiers ---
    $group->get('/dossiers', [DossierController::class, 'list']);
    $group->post('/dossiers', [DossierController::class, 'create']);
    $group->get('/dossiers/{id}', [DossierController::class, 'show']);

    // --- Constantes ---
    $group->post('/dossiers/{id}/constantes', [ConstantesController::class, 'create']);

    // --- Prestations ---
    $group->get('/prestations', [PrestationController::class, 'list']);

    // --- Paiements ---
    $group->get('/paiements', [PaiementController::class, 'list']);
    $group->post('/paiements', [PaiementController::class, 'create']);
    $group->get('/paiements/{id}', [PaiementController::class, 'show']);
    $group->put('/paiements/{id}/confirmer', [PaiementController::class, 'confirmer']);

    // --- File d'attente ---
    $group->get('/file-attente', [FileAttenteController::class, 'list']);
    $group->post('/file-attente', [FileAttenteController::class, 'create']);
    $group->put('/file-attente/{id}', [FileAttenteController::class, 'update']);

    // --- Consultations ---
    $group->get('/consultations', [ConsultationController::class, 'list']);
    $group->post('/consultations', [ConsultationController::class, 'create']);
    $group->get('/consultations/{id}', [ConsultationController::class, 'show']);
    $group->put('/consultations/{id}', [ConsultationController::class, 'update']);

    // --- Soins infirmiers (8.6.1 à 8.6.4) ---
    $group->get('/demandes-soins', [DemandeSoinController::class, 'list']);
    $group->post('/demandes-soins', [DemandeSoinController::class, 'create']);
    $group->post('/attributions-soins', [AttributionSoinController::class, 'create']);
    $group->get('/attributions-soins/{id}', [AttributionSoinController::class, 'show']);
    $group->put('/attributions-soins/{id}', [AttributionSoinController::class, 'update']);
    $group->put('/soins/{id}', [SoinController::class, 'update']);
    $group->get('/salles-soins', [SalleSoinController::class, 'list']);
    $group->get('/types-soins', [TypeSoinController::class, 'list']);

    // --- Plannings / Gardes ---
    $group->get('/plannings', [PlanningController::class, 'list']);
    $group->post('/plannings', [PlanningController::class, 'create']);
    $group->get('/gardes', [GardeController::class, 'list']);
    $group->post('/gardes', [GardeController::class, 'create']);
    $group->put('/gardes/{id}', [GardeController::class, 'update']);

    // --- Administration ---
    $group->get('/roles', [RoleController::class, 'list']);
    $group->get('/users', [UserController::class, 'list']);
    $group->post('/users', [UserController::class, 'create']);
    $group->put('/users/{id}', [UserController::class, 'update']);

    // --- Notifications ---
    $group->get('/notifications', [NotificationController::class, 'list']);
    $group->put('/notifications/{id}/lu', [NotificationController::class, 'marquerLue']);

})->add(JwtMiddleware::class);

$app->run();

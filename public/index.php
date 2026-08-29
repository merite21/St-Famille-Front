<?php

require __DIR__ . '/../vendor/autoload.php';

use App\Controllers\AuthController;
use App\Controllers\PatientController;
use App\Controllers\DossierController;
use App\Controllers\ConstantesController;
use App\Controllers\PaiementController;
use App\Controllers\FileAttenteController;
use App\Controllers\ConsultationController;
use App\Controllers\DemandeSoinController;
use App\Controllers\AttributionSoinController;
use App\Controllers\SoinController;
use App\Controllers\SalleSoinController;
use App\Controllers\PlanningController;
use App\Controllers\GardeController;
use App\Controllers\UserController;
use App\Controllers\NotificationController;
use App\Middleware\JwtMiddleware;
use Slim\Factory\AppFactory;

// Charge les variables du fichier .env dans $_ENV
$dotenv = Dotenv\Dotenv::createImmutable(__DIR__ . '/..');
$dotenv->load();

$app = AppFactory::create();
$app->setBasePath('/Sainte_Famille/public');

// Permet à Flutter (autre origine) d'appeler l'API depuis le navigateur/l'appli.
// En développement on autorise tout ("*"); à restreindre en production.
$app->add(function ($request, $handler) {
    $response = $handler->handle($request);
    return $response
        ->withHeader('Access-Control-Allow-Origin', '*')
        ->withHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization')
        ->withHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
});

$app->addBodyParsingMiddleware();
$app->addErrorMiddleware(true, true, true); // à mettre (false,false,false) en production

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
    $group->post('/dossiers', [DossierController::class, 'create']);
    $group->get('/dossiers/{id}', [DossierController::class, 'show']);

    // --- Constantes ---
    $group->post('/dossiers/{id}/constantes', [ConstantesController::class, 'create']);

    // --- Paiements ---
    $group->post('/paiements', [PaiementController::class, 'create']);
    $group->get('/paiements/{id}', [PaiementController::class, 'show']);
    $group->put('/paiements/{id}/confirmer', [PaiementController::class, 'confirmer']);

    // --- File d'attente ---
    $group->get('/file-attente', [FileAttenteController::class, 'list']);
    $group->post('/file-attente', [FileAttenteController::class, 'create']);
    $group->put('/file-attente/{id}', [FileAttenteController::class, 'update']);

    // --- Consultations ---
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

    // --- Plannings / Gardes ---
    $group->get('/plannings', [PlanningController::class, 'list']);
    $group->post('/plannings', [PlanningController::class, 'create']);
    $group->get('/gardes', [GardeController::class, 'list']);
    $group->post('/gardes', [GardeController::class, 'create']);
    $group->put('/gardes/{id}', [GardeController::class, 'update']);

    // --- Administration ---
    $group->get('/users', [UserController::class, 'list']);
    $group->post('/users', [UserController::class, 'create']);
    $group->put('/users/{id}', [UserController::class, 'update']);

    // --- Notifications ---
    $group->get('/notifications', [NotificationController::class, 'list']);
    $group->put('/notifications/{id}/lu', [NotificationController::class, 'marquerLue']);

})->add(JwtMiddleware::class);

$app->run();

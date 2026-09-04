<?php

namespace App\Controllers;

use App\Database;
use App\Http\JsonResponse;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

/**
 * Ce contrôleur suit exactement les routes /patients et /patients/{id}
 * définies dans api-contract.yaml. Utilise ce fichier comme MODÈLE
 * pour créer les contrôleurs des autres ressources (Dossiers, Paiements, etc.)
 */
class PatientController
{
    /** GET /patients?q=...&page=...&per_page=... */
    public function list(Request $request, Response $response): Response
    {
        $pdo = Database::getConnection();
        $params = $request->getQueryParams();

        $q = trim($params['q'] ?? '');
        $page = max(1, (int) ($params['page'] ?? 1));
        $perPage = min(100, max(1, (int) ($params['per_page'] ?? 20)));
        $offset = ($page - 1) * $perPage;

        if ($q !== '') {
            $where = 'WHERE nom LIKE ? OR prenom LIKE ? OR numero_dossier LIKE ?';
            $searchParam = "%$q%";
            $bindings = [$searchParam, $searchParam, $searchParam];
        } else {
            $where = '';
            $bindings = [];
        }

        // Compter le total (pour la pagination)
        $countStmt = $pdo->prepare("SELECT COUNT(*) FROM patients $where");
        $countStmt->execute($bindings);
        $total = (int) $countStmt->fetchColumn();

        // Récupérer la page demandée
        $stmt = $pdo->prepare(
            "SELECT id, numero_dossier, nom, prenom, date_naissance, sexe, telephone, adresse, created_at
             FROM patients $where
             ORDER BY created_at DESC
             LIMIT $perPage OFFSET $offset"
        );
        $stmt->execute($bindings);
        $patients = $stmt->fetchAll();

        return JsonResponse::send($response, [
            'data' => $patients,
            'meta' => ['page' => $page, 'per_page' => $perPage, 'total' => $total],
        ]);
    }

    /** GET /patients/{id} */
    public function show(Request $request, Response $response, array $args): Response
    {
        $pdo = Database::getConnection();
        $stmt = $pdo->prepare('SELECT * FROM patients WHERE id = ?');
        $stmt->execute([$args['id']]);
        $patient = $stmt->fetch();

        if (!$patient) {
            return JsonResponse::error($response, 'not_found', 'Patient introuvable.', 404);
        }

        return JsonResponse::send($response, $patient);
    }

    /** POST /patients */
    public function create(Request $request, Response $response): Response
    {
        $body = json_decode((string) $request->getBody(), true) ?? [];

        $errors = [];
        if (empty($body['nom'])) $errors['nom'] = ['Le nom est obligatoire'];
        if (empty($body['prenom'])) $errors['prenom'] = ['Le prénom est obligatoire'];
        if (!empty($errors)) {
            return JsonResponse::send($response, ['error' => 'validation_error', 'fields' => $errors], 422);
        }

        $pdo = Database::getConnection();

        // Génère un numéro de dossier simple: SF-2026-000123
        $numeroDossier = 'SF-' . date('Y') . '-' . str_pad(
            (string) ($pdo->query('SELECT COUNT(*) FROM patients')->fetchColumn() + 1),
            6, '0', STR_PAD_LEFT
        );

        $stmt = $pdo->prepare(
            'INSERT INTO patients (numero_dossier, nom, prenom, date_naissance, sexe, telephone, adresse, contact_urgence, created_by, created_at)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())'
        );
        $stmt->execute([
            $numeroDossier,
            $body['nom'],
            $body['prenom'],
            $body['date_naissance'] ?? null,
            $body['sexe'] ?? null,
            $body['telephone'] ?? null,
            $body['adresse'] ?? null,
            $body['contact_urgence'] ?? null,
            $request->getAttribute('user_id'), // fourni par le JwtMiddleware
        ]);

        $newId = $pdo->lastInsertId();

        $stmt = $pdo->prepare('SELECT * FROM patients WHERE id = ?');
        $stmt->execute([$newId]);

        return JsonResponse::send($response, $stmt->fetch(), 201);
    }

    /** PUT /patients/{id} */
    public function update(Request $request, Response $response, array $args): Response
    {
        $pdo = Database::getConnection();

        $stmt = $pdo->prepare('SELECT id FROM patients WHERE id = ?');
        $stmt->execute([$args['id']]);
        if (!$stmt->fetch()) {
            return JsonResponse::error($response, 'not_found', 'Patient introuvable.', 404);
        }

        $body = json_decode((string) $request->getBody(), true) ?? [];

        $stmt = $pdo->prepare(
            'UPDATE patients SET nom = ?, prenom = ?, date_naissance = ?, sexe = ?, telephone = ?, adresse = ?, contact_urgence = ?, updated_at = NOW()
             WHERE id = ?'
        );
        $stmt->execute([
            $body['nom'] ?? null,
            $body['prenom'] ?? null,
            $body['date_naissance'] ?? null,
            $body['sexe'] ?? null,
            $body['telephone'] ?? null,
            $body['adresse'] ?? null,
            $body['contact_urgence'] ?? null,
            $args['id'],
        ]);

        $stmt = $pdo->prepare('SELECT * FROM patients WHERE id = ?');
        $stmt->execute([$args['id']]);

        return JsonResponse::send($response, $stmt->fetch());
    }
}

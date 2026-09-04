<?php

namespace App\Controllers;

use App\Database;
use App\Http\JsonResponse;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

class ConsultationController
{
    /** POST /consultations */
    public function create(Request $request, Response $response): Response
    {
        $body = json_decode((string) $request->getBody(), true) ?? [];

        if (empty($body['dossier_id']) || empty($body['medecin_id'])) {
            return JsonResponse::send($response, [
                'error' => 'validation_error',
                'fields' => [
                    'dossier_id' => ['Requis'],
                    'medecin_id' => ['Requis'],
                ],
            ], 422);
        }

        $pdo = Database::getConnection();

        $dossier = $pdo->prepare('SELECT id FROM dossiers WHERE id = ?');
        $dossier->execute([$body['dossier_id']]);
        if (!$dossier->fetch()) {
            return JsonResponse::error($response, 'not_found', 'Dossier introuvable.', 404);
        }

        $medecin = $pdo->prepare('SELECT id FROM users WHERE id = ?');
        $medecin->execute([$body['medecin_id']]);
        if (!$medecin->fetch()) {
            return JsonResponse::error($response, 'not_found', 'Médecin introuvable.', 404);
        }

        $stmt = $pdo->prepare(
            'INSERT INTO consultations (dossier_id, medecin_id, motif, observations, diagnostic, orientation, debut_at)
             VALUES (?, ?, ?, ?, ?, ?, NOW())'
        );
        $stmt->execute([
            $body['dossier_id'],
            $body['medecin_id'],
            $body['motif'] ?? null,
            $body['observations'] ?? null,
            $body['diagnostic'] ?? null,
            $body['orientation'] ?? 'sans_soins',
        ]);

        return $this->show($request, $response, ['id' => $pdo->lastInsertId()]);
    }

    /** GET /consultations/{id} */
    public function show(Request $request, Response $response, array $args): Response
    {
        $pdo = Database::getConnection();
        $stmt = $pdo->prepare('SELECT * FROM consultations WHERE id = ?');
        $stmt->execute([$args['id']]);
        $consultation = $stmt->fetch();

        if (!$consultation) {
            return JsonResponse::error($response, 'not_found', 'Consultation introuvable.', 404);
        }

        return JsonResponse::send($response, $consultation);
    }

    /** PUT /consultations/{id} — mise à jour / clôture (renseigne fin_at si orientation fournie) */
    public function update(Request $request, Response $response, array $args): Response
    {
        $pdo = Database::getConnection();

        $check = $pdo->prepare('SELECT id FROM consultations WHERE id = ?');
        $check->execute([$args['id']]);
        if (!$check->fetch()) {
            return JsonResponse::error($response, 'not_found', 'Consultation introuvable.', 404);
        }

        $body = json_decode((string) $request->getBody(), true) ?? [];

        $stmt = $pdo->prepare(
            'UPDATE consultations
             SET motif = COALESCE(?, motif),
                 observations = COALESCE(?, observations),
                 diagnostic = COALESCE(?, diagnostic),
                 orientation = COALESCE(?, orientation),
                 fin_at = COALESCE(fin_at, IF(? IS NOT NULL, NOW(), NULL))
             WHERE id = ?'
        );
        $stmt->execute([
            $body['motif'] ?? null,
            $body['observations'] ?? null,
            $body['diagnostic'] ?? null,
            $body['orientation'] ?? null,
            $body['orientation'] ?? null, // sert juste à déclencher fin_at si orientation envoyée
            $args['id'],
        ]);

        return $this->show($request, $response, $args);
    }
}

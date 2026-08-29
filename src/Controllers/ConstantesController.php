<?php

namespace App\Controllers;

use App\Database;
use App\Http\JsonResponse;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

class ConstantesController
{
    /** POST /dossiers/{id}/constantes */
    public function create(Request $request, Response $response, array $args): Response
    {
        $pdo = Database::getConnection();

        $check = $pdo->prepare('SELECT id FROM dossiers WHERE id = ?');
        $check->execute([$args['id']]);
        if (!$check->fetch()) {
            return JsonResponse::error($response, 'not_found', 'Dossier introuvable.', 404);
        }

        $body = json_decode((string) $request->getBody(), true) ?? [];

        $stmt = $pdo->prepare(
            'INSERT INTO constantes
                (dossier_id, temperature, tension_systolique, tension_diastolique, pouls, poids, taille, saturation_o2, saisi_par, created_at)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())'
        );
        $stmt->execute([
            $args['id'],
            $body['temperature'] ?? null,
            $body['tension_systolique'] ?? null,
            $body['tension_diastolique'] ?? null,
            $body['pouls'] ?? null,
            $body['poids'] ?? null,
            $body['taille'] ?? null,
            $body['saturation_o2'] ?? null,
            $request->getAttribute('user_id'),
        ]);

        $stmt = $pdo->prepare('SELECT * FROM constantes WHERE id = ?');
        $stmt->execute([$pdo->lastInsertId()]);

        return JsonResponse::send($response, $stmt->fetch(), 201);
    }
}

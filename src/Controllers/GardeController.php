<?php

namespace App\Controllers;

use App\Database;
use App\Http\JsonResponse;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use PDOException;

class GardeController
{
    /** GET /gardes?date=YYYY-MM-DD */
    public function list(Request $request, Response $response): Response
    {
        $pdo = Database::getConnection();
        $params = $request->getQueryParams();

        $where = '';
        $bindings = [];
        if (!empty($params['date'])) {
            $where = 'WHERE g.date_garde = ?';
            $bindings[] = $params['date'];
        }

        $stmt = $pdo->prepare(
            "SELECT g.*, CONCAT(u.nom, ' ', u.prenom) AS user_nom
             FROM gardes g
             JOIN users u ON u.id = g.user_id
             $where
             ORDER BY g.date_garde"
        );
        $stmt->execute($bindings);

        return JsonResponse::send($response, $stmt->fetchAll());
    }

    /** POST /gardes */
    public function create(Request $request, Response $response): Response
    {
        $body = json_decode((string) $request->getBody(), true) ?? [];

        $errors = [];
        if (empty($body['user_id'])) $errors['user_id'] = ['Requis'];
        if (empty($body['date_garde'])) $errors['date_garde'] = ['Requis'];
        if (empty($body['type_garde'])) $errors['type_garde'] = ['Requis'];
        if (!empty($errors)) {
            return JsonResponse::send($response, ['error' => 'validation_error', 'fields' => $errors], 422);
        }

        $pdo = Database::getConnection();

        $user = $pdo->prepare('SELECT id FROM users WHERE id = ?');
        $user->execute([$body['user_id']]);
        if (!$user->fetch()) {
            return JsonResponse::error($response, 'not_found', 'Utilisateur introuvable.', 404);
        }

        try {
            $stmt = $pdo->prepare(
                'INSERT INTO gardes (user_id, date_garde, type_garde, statut, created_at)
                 VALUES (?, ?, ?, "planifiee", NOW())'
            );
            $stmt->execute([$body['user_id'], $body['date_garde'], $body['type_garde']]);
        } catch (PDOException $e) {
            // La table a une contrainte UNIQUE (user_id, date_garde, type_garde)
            if ($e->getCode() === '23000') {
                return JsonResponse::error($response, 'duplicate_garde', 'Cette personne a déjà une garde à cette date/type.', 409);
            }
            throw $e;
        }

        $stmt = $pdo->prepare('SELECT * FROM gardes WHERE id = ?');
        $stmt->execute([$pdo->lastInsertId()]);

        return JsonResponse::send($response, $stmt->fetch(), 201);
    }

    /** PUT /gardes/{id} — remplacement, annulation, confirmation */
    public function update(Request $request, Response $response, array $args): Response
    {
        $pdo = Database::getConnection();

        $check = $pdo->prepare('SELECT id FROM gardes WHERE id = ?');
        $check->execute([$args['id']]);
        if (!$check->fetch()) {
            return JsonResponse::error($response, 'not_found', 'Garde introuvable.', 404);
        }

        $body = json_decode((string) $request->getBody(), true) ?? [];

        $stmt = $pdo->prepare(
            'UPDATE gardes
             SET statut = COALESCE(?, statut), remplace_par = COALESCE(?, remplace_par)
             WHERE id = ?'
        );
        $stmt->execute([
            $body['statut'] ?? null,
            $body['remplace_par'] ?? null,
            $args['id'],
        ]);

        $stmt = $pdo->prepare('SELECT * FROM gardes WHERE id = ?');
        $stmt->execute([$args['id']]);

        return JsonResponse::send($response, $stmt->fetch());
    }
}

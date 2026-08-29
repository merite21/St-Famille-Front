<?php

namespace App\Controllers;

use App\Database;
use App\Http\JsonResponse;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

class PlanningController
{
    /** GET /plannings?user_id=...&date_debut=...&date_fin=... */
    public function list(Request $request, Response $response): Response
    {
        $pdo = Database::getConnection();
        $params = $request->getQueryParams();

        $where = [];
        $bindings = [];

        if (!empty($params['user_id'])) {
            $where[] = 'pl.user_id = ?';
            $bindings[] = $params['user_id'];
        }
        if (!empty($params['date_debut'])) {
            $where[] = 'pl.date_fin >= ?';
            $bindings[] = $params['date_debut'];
        }
        if (!empty($params['date_fin'])) {
            $where[] = 'pl.date_debut <= ?';
            $bindings[] = $params['date_fin'];
        }

        $whereSql = $where ? 'WHERE ' . implode(' AND ', $where) : '';

        $stmt = $pdo->prepare(
            "SELECT pl.*, CONCAT(u.nom, ' ', u.prenom) AS user_nom
             FROM plannings pl
             JOIN users u ON u.id = pl.user_id
             $whereSql
             ORDER BY pl.date_debut"
        );
        $stmt->execute($bindings);

        return JsonResponse::send($response, $stmt->fetchAll());
    }

    /** POST /plannings */
    public function create(Request $request, Response $response): Response
    {
        $body = json_decode((string) $request->getBody(), true) ?? [];

        $errors = [];
        if (empty($body['user_id'])) $errors['user_id'] = ['Requis'];
        if (empty($body['date_debut'])) $errors['date_debut'] = ['Requis'];
        if (empty($body['date_fin'])) $errors['date_fin'] = ['Requis'];
        if (!empty($errors)) {
            return JsonResponse::send($response, ['error' => 'validation_error', 'fields' => $errors], 422);
        }

        $pdo = Database::getConnection();

        $stmt = $pdo->prepare(
            'INSERT INTO plannings (user_id, date_debut, date_fin, service, created_by, created_at)
             VALUES (?, ?, ?, ?, ?, NOW())'
        );
        $stmt->execute([
            $body['user_id'],
            $body['date_debut'],
            $body['date_fin'],
            $body['service'] ?? null,
            $request->getAttribute('user_id'),
        ]);

        $stmt = $pdo->prepare('SELECT * FROM plannings WHERE id = ?');
        $stmt->execute([$pdo->lastInsertId()]);

        return JsonResponse::send($response, $stmt->fetch(), 201);
    }
}

<?php

namespace App\Controllers;

use App\Database;
use App\Http\JsonResponse;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

/**
 * Liste des rôles. Nécessaire pour que le front puisse proposer un
 * choix de rôle lors de la création d'un utilisateur (POST /users
 * exige un role_id valide).
 */
class RoleController
{
    /** GET /roles */
    public function list(Request $request, Response $response): Response
    {
        $pdo = Database::getConnection();
        $stmt = $pdo->query('SELECT id, nom, description FROM roles ORDER BY nom');
        return JsonResponse::send($response, $stmt->fetchAll());
    }
}

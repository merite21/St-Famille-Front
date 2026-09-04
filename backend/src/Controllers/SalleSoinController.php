<?php

namespace App\Controllers;

use App\Database;
use App\Http\JsonResponse;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

class SalleSoinController
{
    /** GET /salles-soins */
    public function list(Request $request, Response $response): Response
    {
        $pdo = Database::getConnection();
        $stmt = $pdo->query('SELECT * FROM salles_soins ORDER BY nom');
        return JsonResponse::send($response, $stmt->fetchAll());
    }
}

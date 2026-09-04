<?php

namespace App\Controllers;

use App\Database;
use App\Http\JsonResponse;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

class TypeSoinController
{
    /** GET /types-soins */
    public function list(Request $request, Response $response): Response
    {
        $pdo = Database::getConnection();
        $stmt = $pdo->query('SELECT * FROM types_soins WHERE actif = 1 ORDER BY libelle');
        return JsonResponse::send($response, $stmt->fetchAll());
    }
}

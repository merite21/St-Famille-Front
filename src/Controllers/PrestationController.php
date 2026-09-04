<?php

namespace App\Controllers;

use App\Database;
use App\Http\JsonResponse;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

/**
 * Catalogue des prestations facturables. Nécessaire pour que le front
 * puisse proposer un choix de prestation lors de la création d'un
 * paiement (POST /paiements exige un prestation_id valide).
 */
class PrestationController
{
    /** GET /prestations */
    public function list(Request $request, Response $response): Response
    {
        $pdo = Database::getConnection();
        $stmt = $pdo->query('SELECT * FROM prestations WHERE actif = 1 ORDER BY libelle');
        return JsonResponse::send($response, $stmt->fetchAll());
    }
}

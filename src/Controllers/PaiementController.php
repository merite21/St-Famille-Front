<?php

namespace App\Controllers;

use App\Database;
use App\Http\JsonResponse;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

class PaiementController
{
    /** POST /paiements — créer une demande de paiement */
    public function create(Request $request, Response $response): Response
    {
        $body = json_decode((string) $request->getBody(), true) ?? [];

        if (empty($body['dossier_id']) || empty($body['prestation_id'])) {
            return JsonResponse::send($response, [
                'error' => 'validation_error',
                'fields' => [
                    'dossier_id' => ['Requis'],
                    'prestation_id' => ['Requis'],
                ],
            ], 422);
        }

        $pdo = Database::getConnection();

        $prestation = $pdo->prepare('SELECT montant_fcfa FROM prestations WHERE id = ? AND actif = 1');
        $prestation->execute([$body['prestation_id']]);
        $prestationRow = $prestation->fetch();

        if (!$prestationRow) {
            return JsonResponse::error($response, 'not_found', 'Prestation introuvable ou inactive.', 404);
        }

        $stmt = $pdo->prepare(
            'INSERT INTO paiements (dossier_id, prestation_id, montant_fcfa, statut, demande_par, demande_at)
             VALUES (?, ?, ?, "en_attente", ?, NOW())'
        );
        $stmt->execute([
            $body['dossier_id'],
            $body['prestation_id'],
            $prestationRow['montant_fcfa'],
            $request->getAttribute('user_id'),
        ]);

        return $this->show($request, $response, ['id' => $pdo->lastInsertId()]);
    }

    /** GET /paiements/{id} — consulter le statut */
    public function show(Request $request, Response $response, array $args): Response
    {
        $pdo = Database::getConnection();
        $stmt = $pdo->prepare('SELECT * FROM paiements WHERE id = ?');
        $stmt->execute([$args['id']]);
        $paiement = $stmt->fetch();

        if (!$paiement) {
            return JsonResponse::error($response, 'not_found', 'Paiement introuvable.', 404);
        }

        return JsonResponse::send($response, $paiement);
    }

    /** PUT /paiements/{id}/confirmer — le/la caissier·ère confirme l'encaissement */
    public function confirmer(Request $request, Response $response, array $args): Response
    {
        $pdo = Database::getConnection();

        $check = $pdo->prepare('SELECT statut FROM paiements WHERE id = ?');
        $check->execute([$args['id']]);
        $existing = $check->fetch();

        if (!$existing) {
            return JsonResponse::error($response, 'not_found', 'Paiement introuvable.', 404);
        }
        if ($existing['statut'] === 'confirme') {
            return JsonResponse::error($response, 'already_confirmed', 'Ce paiement est déjà confirmé.', 409);
        }

        $body = json_decode((string) $request->getBody(), true) ?? [];

        $stmt = $pdo->prepare(
            'UPDATE paiements
             SET statut = "confirme", reference_externe = ?, confirme_par = ?, confirme_at = NOW()
             WHERE id = ?'
        );
        $stmt->execute([
            $body['reference_externe'] ?? null,
            $request->getAttribute('user_id'),
            $args['id'],
        ]);

        return $this->show($request, $response, $args);
    }
}

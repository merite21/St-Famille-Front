<?php

namespace App\Controllers;

use App\Database;
use App\Http\JsonResponse;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

/**
 * Étape 1 du circuit soins (cahier des charges 8.6.1) :
 * le médecin crée une demande de soins. Il NE PEUT PAS l'attribuer lui-même
 * (voir AttributionSoinController + règle 8.6.5).
 */
class DemandeSoinController
{
    /** GET /demandes-soins?statut=... — vue "salle d'attribution" pour l'infirmier responsable */
    public function list(Request $request, Response $response): Response
    {
        $pdo = Database::getConnection();
        $params = $request->getQueryParams();

        $where = '';
        $bindings = [];
        if (!empty($params['statut'])) {
            $where = 'WHERE ds.statut = ?';
            $bindings[] = $params['statut'];
        }

        $stmt = $pdo->prepare(
            "SELECT ds.id, ds.dossier_id, ds.priorite, ds.instructions, ds.statut, ds.created_at,
                    t.libelle AS type_soin,
                    CONCAT(p.nom, ' ', p.prenom) AS patient_nom,
                    p.numero_dossier,
                    CONCAT(m.nom, ' ', m.prenom) AS medecin_nom
             FROM demandes_soins ds
             JOIN types_soins t ON t.id = ds.type_soin_id
             JOIN dossiers d ON d.id = ds.dossier_id
             JOIN patients p ON p.id = d.patient_id
             JOIN users m ON m.id = ds.medecin_id
             $where
             ORDER BY FIELD(ds.priorite, 'urgente', 'normale'), ds.created_at ASC"
        );
        $stmt->execute($bindings);

        return JsonResponse::send($response, $stmt->fetchAll());
    }

    /** POST /demandes-soins — créée par le médecin (8.6.1) */
    public function create(Request $request, Response $response): Response
    {
        $body = json_decode((string) $request->getBody(), true) ?? [];

        $errors = [];
        if (empty($body['dossier_id'])) $errors['dossier_id'] = ['Requis'];
        if (empty($body['type_soin_id'])) $errors['type_soin_id'] = ['Requis'];
        if (empty($body['medecin_id'])) $errors['medecin_id'] = ['Requis'];
        if (!empty($errors)) {
            return JsonResponse::send($response, ['error' => 'validation_error', 'fields' => $errors], 422);
        }

        $pdo = Database::getConnection();

        $stmt = $pdo->prepare(
            'INSERT INTO demandes_soins
                (dossier_id, consultation_id, type_soin_id, medecin_id, priorite, instructions, statut, created_at)
             VALUES (?, ?, ?, ?, ?, ?, "en_attente", NOW())'
        );
        $stmt->execute([
            $body['dossier_id'],
            $body['consultation_id'] ?? null,
            $body['type_soin_id'],
            $body['medecin_id'],
            $body['priorite'] ?? 'normale',
            $body['instructions'] ?? null,
        ]);

        $stmt = $pdo->prepare('SELECT * FROM demandes_soins WHERE id = ?');
        $stmt->execute([$pdo->lastInsertId()]);

        return JsonResponse::send($response, $stmt->fetch(), 201);
    }
}

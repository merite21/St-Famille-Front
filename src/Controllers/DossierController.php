<?php

namespace App\Controllers;

use App\Database;
use App\Http\JsonResponse;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

/**
 * Un "dossier" = un épisode de prise en charge (un passage du patient
 * à l'hôpital). Un même patient peut avoir plusieurs dossiers au fil du temps.
 */
class DossierController
{
    /** POST /dossiers */
    public function create(Request $request, Response $response): Response
    {
        $body = json_decode((string) $request->getBody(), true) ?? [];

        if (empty($body['patient_id'])) {
            return JsonResponse::send($response, [
                'error' => 'validation_error',
                'fields' => ['patient_id' => ['Le patient_id est obligatoire']],
            ], 422);
        }

        $pdo = Database::getConnection();

        // On vérifie que le patient existe vraiment avant de créer le dossier
        $check = $pdo->prepare('SELECT id FROM patients WHERE id = ?');
        $check->execute([$body['patient_id']]);
        if (!$check->fetch()) {
            return JsonResponse::error($response, 'not_found', 'Patient introuvable.', 404);
        }

        $stmt = $pdo->prepare(
            'INSERT INTO dossiers (patient_id, statut, motif, ouvert_par, ouvert_at)
             VALUES (?, "ouvert", ?, ?, NOW())'
        );
        $stmt->execute([
            $body['patient_id'],
            $body['motif'] ?? null,
            $request->getAttribute('user_id'),
        ]);

        $newId = $pdo->lastInsertId();

        return $this->show($request, $response, ['id' => $newId]);
    }

    /** GET /dossiers/{id} */
    public function show(Request $request, Response $response, array $args): Response
    {
        $pdo = Database::getConnection();

        // On récupère le dossier ET les infos du patient associé en une seule requête
        $stmt = $pdo->prepare(
            'SELECT
                d.id, d.statut, d.motif, d.ouvert_at, d.cloture_at,
                p.id AS patient_id, p.numero_dossier, p.nom, p.prenom,
                p.date_naissance, p.sexe, p.telephone
             FROM dossiers d
             JOIN patients p ON p.id = d.patient_id
             WHERE d.id = ?'
        );
        $stmt->execute([$args['id']]);
        $row = $stmt->fetch();

        if (!$row) {
            return JsonResponse::error($response, 'not_found', 'Dossier introuvable.', 404);
        }

        // On reformate la réponse pour respecter la structure du contrat API
        // (un objet "patient" imbriqué, comme défini dans api-contract.yaml)
        $dossier = [
            'id' => $row['id'],
            'statut' => $row['statut'],
            'motif' => $row['motif'],
            'ouvert_at' => $row['ouvert_at'],
            'cloture_at' => $row['cloture_at'],
            'patient' => [
                'id' => $row['patient_id'],
                'numero_dossier' => $row['numero_dossier'],
                'nom' => $row['nom'],
                'prenom' => $row['prenom'],
                'date_naissance' => $row['date_naissance'],
                'sexe' => $row['sexe'],
                'telephone' => $row['telephone'],
            ],
        ];

        return JsonResponse::send($response, $dossier);
    }
}

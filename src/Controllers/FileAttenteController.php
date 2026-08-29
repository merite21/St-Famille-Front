<?php

namespace App\Controllers;

use App\Database;
use App\Http\JsonResponse;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

class FileAttenteController
{
    /** GET /file-attente?statut=...&medecin_id=... */
    public function list(Request $request, Response $response): Response
    {
        $pdo = Database::getConnection();
        $params = $request->getQueryParams();

        $where = [];
        $bindings = [];

        if (!empty($params['statut'])) {
            $where[] = 'f.statut = ?';
            $bindings[] = $params['statut'];
        }
        if (!empty($params['medecin_id'])) {
            $where[] = 'f.medecin_id = ?';
            $bindings[] = $params['medecin_id'];
        }

        $whereSql = $where ? 'WHERE ' . implode(' AND ', $where) : '';

        $stmt = $pdo->prepare(
            "SELECT f.id, f.dossier_id, f.medecin_id, f.priorite, f.statut, f.entree_at,
                    CONCAT(p.nom, ' ', p.prenom) AS patient_nom
             FROM file_attente f
             JOIN dossiers d ON d.id = f.dossier_id
             JOIN patients p ON p.id = d.patient_id
             $whereSql
             ORDER BY FIELD(f.priorite, 'urgente', 'normale'), f.entree_at ASC"
        );
        $stmt->execute($bindings);

        return JsonResponse::send($response, $stmt->fetchAll());
    }

    /** POST /file-attente — ajouter un dossier à la file (après paiement confirmé) */
    public function create(Request $request, Response $response): Response
    {
        $body = json_decode((string) $request->getBody(), true) ?? [];

        if (empty($body['dossier_id'])) {
            return JsonResponse::send($response, [
                'error' => 'validation_error',
                'fields' => ['dossier_id' => ['Requis']],
            ], 422);
        }

        $pdo = Database::getConnection();

        // Règle métier : on vérifie qu'un paiement est bien confirmé pour ce dossier
        $paiement = $pdo->prepare(
            "SELECT id FROM paiements WHERE dossier_id = ? AND statut = 'confirme' LIMIT 1"
        );
        $paiement->execute([$body['dossier_id']]);
        if (!$paiement->fetch()) {
            return JsonResponse::error(
                $response,
                'payment_required',
                'Aucun paiement confirmé pour ce dossier. Impossible d\'entrer en file d\'attente.',
                409
            );
        }

        $stmt = $pdo->prepare(
            'INSERT INTO file_attente (dossier_id, priorite, statut, entree_at)
             VALUES (?, ?, "en_attente", NOW())'
        );
        $stmt->execute([
            $body['dossier_id'],
            $body['priorite'] ?? 'normale',
        ]);

        $stmt = $pdo->prepare('SELECT * FROM file_attente WHERE id = ?');
        $stmt->execute([$pdo->lastInsertId()]);

        return JsonResponse::send($response, $stmt->fetch(), 201);
    }

    /** PUT /file-attente/{id} — changer le statut (appelé, en_consultation, terminé...) */
    public function update(Request $request, Response $response, array $args): Response
    {
        $pdo = Database::getConnection();

        $check = $pdo->prepare('SELECT id FROM file_attente WHERE id = ?');
        $check->execute([$args['id']]);
        if (!$check->fetch()) {
            return JsonResponse::error($response, 'not_found', 'Entrée de file introuvable.', 404);
        }

        $body = json_decode((string) $request->getBody(), true) ?? [];
        $statut = $body['statut'] ?? null;

        $validStatuts = ['en_attente', 'appele', 'en_consultation', 'termine', 'annule'];
        if (!in_array($statut, $validStatuts, true)) {
            return JsonResponse::send($response, [
                'error' => 'validation_error',
                'fields' => ['statut' => ['Doit être l\'un de : ' . implode(', ', $validStatuts)]],
            ], 422);
        }

        $timestampField = match ($statut) {
            'appele' => 'appele_at',
            'termine' => 'termine_at',
            default => null,
        };

        $sql = 'UPDATE file_attente SET statut = ?, medecin_id = COALESCE(?, medecin_id)';
        $bindings = [$statut, $body['medecin_id'] ?? null];

        if ($timestampField) {
            $sql .= ", $timestampField = NOW()";
        }
        $sql .= ' WHERE id = ?';
        $bindings[] = $args['id'];

        $pdo->prepare($sql)->execute($bindings);

        $stmt = $pdo->prepare('SELECT * FROM file_attente WHERE id = ?');
        $stmt->execute([$args['id']]);

        return JsonResponse::send($response, $stmt->fetch());
    }
}

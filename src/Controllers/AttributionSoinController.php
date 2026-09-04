<?php

namespace App\Controllers;

use App\Database;
use App\Http\JsonResponse;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

/**
 * Étape 2 du circuit soins (cahier des charges 8.6.2) :
 * l'infirmier responsable attribue une demande à un infirmier + une salle.
 * Rappel règle 8.6.5 : ce n'est jamais le médecin qui fait cette étape.
 */
class AttributionSoinController
{
    /** POST /attributions-soins */
    public function create(Request $request, Response $response): Response
    {
        $body = json_decode((string) $request->getBody(), true) ?? [];

        if (empty($body['demande_soin_id']) || empty($body['infirmier_id'])) {
            return JsonResponse::send($response, [
                'error' => 'validation_error',
                'fields' => [
                    'demande_soin_id' => ['Requis'],
                    'infirmier_id' => ['Requis'],
                ],
            ], 422);
        }

        $pdo = Database::getConnection();

        $demande = $pdo->prepare('SELECT statut FROM demandes_soins WHERE id = ?');
        $demande->execute([$body['demande_soin_id']]);
        $demandeRow = $demande->fetch();

        if (!$demandeRow) {
            return JsonResponse::error($response, 'not_found', 'Demande de soins introuvable.', 404);
        }
        if ($demandeRow['statut'] !== 'en_attente') {
            return JsonResponse::error($response, 'already_attributed', 'Cette demande a déjà été traitée.', 409);
        }

        $infirmier = $pdo->prepare('SELECT id FROM users WHERE id = ?');
        $infirmier->execute([$body['infirmier_id']]);
        if (!$infirmier->fetch()) {
            return JsonResponse::error($response, 'not_found', 'Infirmier introuvable.', 404);
        }

        if (!empty($body['salle_soin_id'])) {
            $salle = $pdo->prepare('SELECT id FROM salles_soins WHERE id = ?');
            $salle->execute([$body['salle_soin_id']]);
            if (!$salle->fetch()) {
                return JsonResponse::error($response, 'not_found', 'Salle de soins introuvable.', 404);
            }
        }

        $pdo->beginTransaction();
        try {
            $stmt = $pdo->prepare(
                'INSERT INTO attributions_soins (demande_soin_id, infirmier_id, salle_soin_id, attribue_par, attribue_at)
                 VALUES (?, ?, ?, ?, NOW())'
            );
            $stmt->execute([
                $body['demande_soin_id'],
                $body['infirmier_id'],
                $body['salle_soin_id'] ?? null,
                $request->getAttribute('user_id'),
            ]);
            $attributionId = $pdo->lastInsertId();

            $pdo->prepare('UPDATE demandes_soins SET statut = "attribue" WHERE id = ?')
                ->execute([$body['demande_soin_id']]);

            // Crée automatiquement la ligne "soins" associée, prête à être complétée (8.6.4)
            $pdo->prepare('INSERT INTO soins (attribution_id, valide) VALUES (?, 0)')
                ->execute([$attributionId]);

            $pdo->commit();
        } catch (\Throwable $e) {
            $pdo->rollBack();
            error_log('Erreur attribution soin: ' . $e->getMessage());
            return JsonResponse::error($response, 'server_error', 'Impossible d\'attribuer ce soin.', 500);
        }

        return $this->show($request, $response, ['id' => $attributionId]);
    }

    /** GET /attributions-soins/{id} — vue "salle de soins" pour l'infirmier exécutant (8.6.3) */
    public function show(Request $request, Response $response, array $args): Response
    {
        $pdo = Database::getConnection();
        $stmt = $pdo->prepare(
            "SELECT a.id, a.statut, a.attribue_at, a.salle_soin_id, s.nom AS salle_nom,
                    ds.priorite, ds.instructions,
                    t.libelle AS type_soin,
                    CONCAT(p.nom, ' ', p.prenom) AS patient_nom, p.numero_dossier,
                    CONCAT(m.nom, ' ', m.prenom) AS medecin_nom,
                    so.id AS soin_id
             FROM attributions_soins a
             JOIN demandes_soins ds ON ds.id = a.demande_soin_id
             JOIN types_soins t ON t.id = ds.type_soin_id
             JOIN dossiers d ON d.id = ds.dossier_id
             JOIN patients p ON p.id = d.patient_id
             JOIN users m ON m.id = ds.medecin_id
             LEFT JOIN salles_soins s ON s.id = a.salle_soin_id
             LEFT JOIN soins so ON so.attribution_id = a.id
             WHERE a.id = ?"
        );
        $stmt->execute([$args['id']]);
        $row = $stmt->fetch();

        if (!$row) {
            return JsonResponse::error($response, 'not_found', 'Attribution introuvable.', 404);
        }

        return JsonResponse::send($response, $row);
    }

    /** PUT /attributions-soins/{id} — changement de statut (en_cours, termine, reporte...) */
    public function update(Request $request, Response $response, array $args): Response
    {
        $pdo = Database::getConnection();

        $check = $pdo->prepare('SELECT id FROM attributions_soins WHERE id = ?');
        $check->execute([$args['id']]);
        if (!$check->fetch()) {
            return JsonResponse::error($response, 'not_found', 'Attribution introuvable.', 404);
        }

        $body = json_decode((string) $request->getBody(), true) ?? [];
        $validStatuts = ['attribue', 'en_cours', 'termine', 'reporte', 'annule', 'patient_absent'];

        if (!in_array($body['statut'] ?? null, $validStatuts, true)) {
            return JsonResponse::send($response, [
                'error' => 'validation_error',
                'fields' => ['statut' => ['Doit être l\'un de : ' . implode(', ', $validStatuts)]],
            ], 422);
        }

        $pdo->prepare('UPDATE attributions_soins SET statut = ? WHERE id = ?')
            ->execute([$body['statut'], $args['id']]);

        // On garde la demande de soins synchronisée avec l'attribution
        $pdo->prepare(
            'UPDATE demandes_soins ds
             JOIN attributions_soins a ON a.demande_soin_id = ds.id
             SET ds.statut = ?
             WHERE a.id = ?'
        )->execute([$body['statut'], $args['id']]);

        return $this->show($request, $response, $args);
    }
}

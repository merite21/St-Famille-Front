<?php

namespace App\Controllers;

use App\Database;
use App\Http\JsonResponse;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

/**
 * Étape 3 du circuit soins (cahier des charges 8.6.4) :
 * l'infirmier renseigne la réalisation du soin et le valide.
 * La ligne "soins" est créée automatiquement lors de l'attribution
 * (voir AttributionSoinController::create), donc ici on ne fait que la MAJ.
 */
class SoinController
{
    /** PUT /soins/{id} */
    public function update(Request $request, Response $response, array $args): Response
    {
        $pdo = Database::getConnection();

        $check = $pdo->prepare('SELECT id, attribution_id FROM soins WHERE id = ?');
        $check->execute([$args['id']]);
        $soin = $check->fetch();

        if (!$soin) {
            return JsonResponse::error($response, 'not_found', 'Soin introuvable.', 404);
        }

        $body = json_decode((string) $request->getBody(), true) ?? [];
        $valide = !empty($body['valide']);

        $stmt = $pdo->prepare(
            'UPDATE soins
             SET heure_soin = COALESCE(?, heure_soin),
                 soin_realise = COALESCE(?, soin_realise),
                 observations = COALESCE(?, observations),
                 constantes_id = COALESCE(?, constantes_id),
                 incident = COALESCE(?, incident),
                 commentaire = COALESCE(?, commentaire),
                 valide = ?,
                 valide_par = IF(?, ?, valide_par),
                 valide_at = IF(?, NOW(), valide_at)
             WHERE id = ?'
        );
        $stmt->execute([
            $body['heure_soin'] ?? null,
            $body['soin_realise'] ?? null,
            $body['observations'] ?? null,
            $body['constantes_id'] ?? null,
            $body['incident'] ?? null,
            $body['commentaire'] ?? null,
            $valide ? 1 : 0,
            $valide, $request->getAttribute('user_id'),
            $valide,
            $args['id'],
        ]);

        // Si le soin est validé, on clôt aussi l'attribution correspondante
        if ($valide) {
            $pdo->prepare('UPDATE attributions_soins SET statut = "termine" WHERE id = ?')
                ->execute([$soin['attribution_id']]);
            $pdo->prepare(
                'UPDATE demandes_soins ds
                 JOIN attributions_soins a ON a.demande_soin_id = ds.id
                 SET ds.statut = "termine"
                 WHERE a.id = ?'
            )->execute([$soin['attribution_id']]);
        }

        $stmt = $pdo->prepare('SELECT * FROM soins WHERE id = ?');
        $stmt->execute([$args['id']]);

        return JsonResponse::send($response, $stmt->fetch());
    }
}

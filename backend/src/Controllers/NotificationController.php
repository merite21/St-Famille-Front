<?php

namespace App\Controllers;

use App\Database;
use App\Http\JsonResponse;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

class NotificationController
{
    /** GET /notifications?lu=true|false — pour l'utilisateur connecté uniquement */
    public function list(Request $request, Response $response): Response
    {
        $pdo = Database::getConnection();
        $params = $request->getQueryParams();
        $userId = $request->getAttribute('user_id');

        $where = 'WHERE user_id = ?';
        $bindings = [$userId];

        if (isset($params['lu'])) {
            $where .= ' AND lu = ?';
            $bindings[] = filter_var($params['lu'], FILTER_VALIDATE_BOOLEAN) ? 1 : 0;
        }

        $stmt = $pdo->prepare("SELECT * FROM notifications $where ORDER BY created_at DESC");
        $stmt->execute($bindings);

        return JsonResponse::send($response, $stmt->fetchAll());
    }

    /** PUT /notifications/{id}/lu — marquer comme lue */
    public function marquerLue(Request $request, Response $response, array $args): Response
    {
        $pdo = Database::getConnection();
        $userId = $request->getAttribute('user_id');

        // On ne peut marquer comme lue que SES PROPRES notifications
        $stmt = $pdo->prepare('UPDATE notifications SET lu = 1 WHERE id = ? AND user_id = ?');
        $stmt->execute([$args['id'], $userId]);

        return $response->withStatus(204);
    }

    /**
     * Petit helper interne, à appeler depuis les autres contrôleurs
     * quand un événement notifiable se produit (paiement confirmé, etc.)
     * Pas exposé en tant que route.
     */
    public static function creer(int $userId, string $type, string $contenu, ?string $lienRessource = null): void
    {
        $pdo = Database::getConnection();
        $stmt = $pdo->prepare(
            'INSERT INTO notifications (user_id, type, contenu, lien_ressource, lu, created_at)
             VALUES (?, ?, ?, ?, 0, NOW())'
        );
        $stmt->execute([$userId, $type, $contenu, $lienRessource]);
    }
}

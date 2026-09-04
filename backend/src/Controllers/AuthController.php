<?php

namespace App\Controllers;

use App\Database;
use App\Http\JsonResponse;
use Firebase\JWT\JWT;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

class AuthController
{
    /**
     * POST /auth/login
     * Reçoit { "matricule": "...", "password": "..." }
     * Renvoie un access_token si les identifiants sont bons.
     */
    public function login(Request $request, Response $response): Response
    {
        $body = json_decode((string) $request->getBody(), true) ?? [];
        $matricule = trim($body['matricule'] ?? '');
        $password = $body['password'] ?? '';

        if ($matricule === '' || $password === '') {
            return JsonResponse::error($response, 'validation_error', 'Matricule et mot de passe requis.', 422);
        }

        $pdo = Database::getConnection();

        // On récupère l'utilisateur + le nom de son rôle en une seule requête (JOIN)
        $stmt = $pdo->prepare(
            'SELECT u.id, u.matricule, u.nom, u.prenom, u.password_hash, u.actif, r.nom AS role
             FROM users u
             JOIN roles r ON r.id = u.role_id
             WHERE u.matricule = ?'
        );
        $stmt->execute([$matricule]);
        $user = $stmt->fetch();

        // On vérifie le mot de passe avec password_verify (jamais de comparaison en clair !)
        if (!$user || !$user['actif'] || !password_verify($password, $user['password_hash'])) {
            return JsonResponse::error($response, 'invalid_credentials', 'Matricule ou mot de passe incorrect.', 401);
        }

        $expiry = (int) $_ENV['JWT_EXPIRY_SECONDS'];
        $now = time();

        $payload = [
            'sub' => $user['id'],       // "subject" = à qui appartient le token
            'role' => $user['role'],
            'iat' => $now,               // issued at
            'exp' => $now + $expiry,     // expiration
        ];

        $token = JWT::encode($payload, $_ENV['JWT_SECRET'], 'HS256');

        return JsonResponse::send($response, [
            'access_token' => $token,
            'expires_in' => $expiry,
            'user' => [
                'id' => $user['id'],
                'matricule' => $user['matricule'],
                'nom' => $user['nom'],
                'prenom' => $user['prenom'],
                'role' => $user['role'],
            ],
        ]);
    }
}

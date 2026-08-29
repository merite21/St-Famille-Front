<?php

namespace App\Controllers;

use App\Database;
use App\Http\JsonResponse;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

class UserController
{
    /** GET /users */
    public function list(Request $request, Response $response): Response
    {
        $pdo = Database::getConnection();
        $stmt = $pdo->query(
            'SELECT u.id, u.matricule, u.nom, u.prenom, u.email, u.telephone, u.actif, r.nom AS role
             FROM users u
             JOIN roles r ON r.id = u.role_id
             ORDER BY u.nom'
        );
        return JsonResponse::send($response, $stmt->fetchAll());
    }

    /** POST /users — création par un administrateur */
    public function create(Request $request, Response $response): Response
    {
        $body = json_decode((string) $request->getBody(), true) ?? [];

        $errors = [];
        if (empty($body['matricule'])) $errors['matricule'] = ['Requis'];
        if (empty($body['nom'])) $errors['nom'] = ['Requis'];
        if (empty($body['prenom'])) $errors['prenom'] = ['Requis'];
        if (empty($body['role_id'])) $errors['role_id'] = ['Requis'];
        if (empty($body['password'])) $errors['password'] = ['Requis à la création'];
        if (!empty($errors)) {
            return JsonResponse::send($response, ['error' => 'validation_error', 'fields' => $errors], 422);
        }

        $pdo = Database::getConnection();

        $stmt = $pdo->prepare(
            'INSERT INTO users (role_id, matricule, nom, prenom, email, telephone, password_hash, actif, created_at)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())'
        );
        $stmt->execute([
            $body['role_id'],
            $body['matricule'],
            $body['nom'],
            $body['prenom'],
            $body['email'] ?? null,
            $body['telephone'] ?? null,
            password_hash($body['password'], PASSWORD_DEFAULT), // jamais de mot de passe en clair !
            $body['actif'] ?? 1,
        ]);

        return $this->find($pdo->lastInsertId(), $response);
    }

    /** PUT /users/{id} — modification (rôle, statut actif, infos, mot de passe optionnel) */
    public function update(Request $request, Response $response, array $args): Response
    {
        $pdo = Database::getConnection();

        $check = $pdo->prepare('SELECT id FROM users WHERE id = ?');
        $check->execute([$args['id']]);
        if (!$check->fetch()) {
            return JsonResponse::error($response, 'not_found', 'Utilisateur introuvable.', 404);
        }

        $body = json_decode((string) $request->getBody(), true) ?? [];

        $fields = [
            'nom' => $body['nom'] ?? null,
            'prenom' => $body['prenom'] ?? null,
            'email' => $body['email'] ?? null,
            'telephone' => $body['telephone'] ?? null,
            'role_id' => $body['role_id'] ?? null,
            'actif' => array_key_exists('actif', $body) ? (int) $body['actif'] : null,
        ];

        $sql = 'UPDATE users SET
                    nom = COALESCE(?, nom), prenom = COALESCE(?, prenom), email = COALESCE(?, email),
                    telephone = COALESCE(?, telephone), role_id = COALESCE(?, role_id), actif = COALESCE(?, actif)';
        $bindings = array_values($fields);

        if (!empty($body['password'])) {
            $sql .= ', password_hash = ?';
            $bindings[] = password_hash($body['password'], PASSWORD_DEFAULT);
        }

        $sql .= ' WHERE id = ?';
        $bindings[] = $args['id'];

        $pdo->prepare($sql)->execute($bindings);

        return $this->find($args['id'], $response);
    }

    private function find(int|string $id, Response $response): Response
    {
        $pdo = Database::getConnection();
        $stmt = $pdo->prepare(
            'SELECT u.id, u.matricule, u.nom, u.prenom, u.email, u.telephone, u.actif, r.nom AS role
             FROM users u JOIN roles r ON r.id = u.role_id WHERE u.id = ?'
        );
        $stmt->execute([$id]);
        return JsonResponse::send($response, $stmt->fetch());
    }
}

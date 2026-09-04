<?php

namespace App\Middleware;

use App\Http\JsonResponse;
use Firebase\JWT\ExpiredException;
use Firebase\JWT\JWT;
use Firebase\JWT\Key;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Server\RequestHandlerInterface as RequestHandler;
use Slim\Psr7\Response as SlimResponse;

/**
 * S'exécute AVANT chaque route protégée.
 * Vérifie que le header "Authorization: Bearer xxx" contient un token JWT valide.
 * Si oui -> on ajoute les infos de l'utilisateur à la requête et on continue.
 * Si non -> on renvoie directement une erreur 401, la route n'est jamais atteinte.
 */
class JwtMiddleware
{
    public function __invoke(Request $request, RequestHandler $handler): Response
    {
        $authHeader = $request->getHeaderLine('Authorization');

        if (!$authHeader || !str_starts_with($authHeader, 'Bearer ')) {
            return JsonResponse::error(
                new SlimResponse(),
                'unauthorized',
                'Token manquant. Ajoute un header "Authorization: Bearer <token>".',
                401
            );
        }

        $token = substr($authHeader, 7); // enlève "Bearer "

        try {
            $decoded = JWT::decode($token, new Key($_ENV['JWT_SECRET'], 'HS256'));
        } catch (ExpiredException $e) {
            return JsonResponse::error(new SlimResponse(), 'token_expired', 'Le token a expiré, reconnecte-toi.', 401);
        } catch (\Exception $e) {
            return JsonResponse::error(new SlimResponse(), 'invalid_token', 'Token invalide.', 401);
        }

        // On rend les infos de l'utilisateur connecté disponibles dans le reste de la requête
        $request = $request->withAttribute('user_id', $decoded->sub);
        $request = $request->withAttribute('user_role', $decoded->role);

        return $handler->handle($request);
    }
}

<?php

namespace App\Http;

use Psr\Http\Message\ResponseInterface as Response;

/**
 * Petit helper pour ne pas répéter le même code partout :
 * transformer un tableau PHP en réponse JSON avec le bon code HTTP.
 */
class JsonResponse
{
    public static function send(Response $response, array $data, int $status = 200): Response
    {
        $response->getBody()->write(json_encode($data, JSON_UNESCAPED_UNICODE));
        return $response
            ->withHeader('Content-Type', 'application/json')
            ->withStatus($status);
    }

    public static function error(Response $response, string $errorCode, string $message, int $status = 400): Response
    {
        return self::send($response, [
            'error' => $errorCode,
            'message' => $message,
        ], $status);
    }
}

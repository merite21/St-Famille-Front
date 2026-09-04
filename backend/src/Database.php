<?php

namespace App;

use PDO;
use PDOException;

/**
 * Petite classe qui ouvre UNE SEULE connexion PDO à MySQL
 * et la renvoie à qui en a besoin (pattern "singleton").
 *
 * On l'utilise dans les contrôleurs comme ceci :
 *   $pdo = Database::getConnection();
 *   $stmt = $pdo->prepare("SELECT * FROM patients WHERE id = ?");
 */
class Database
{
    private static ?PDO $instance = null;

    public static function getConnection(): PDO
    {
        if (self::$instance === null) {
            $host = $_ENV['DB_HOST'];
            $port = $_ENV['DB_PORT'];
            $dbname = $_ENV['DB_NAME'];
            $user = $_ENV['DB_USER'];
            $pass = $_ENV['DB_PASS'];

            $dsn = "mysql:host=$host;port=$port;dbname=$dbname;charset=utf8mb4";

            try {
                self::$instance = new PDO($dsn, $user, $pass, [
                    // Les erreurs SQL deviennent des exceptions PHP -> plus facile à gérer
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    // Les résultats sont renvoyés sous forme de tableaux associatifs
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                ]);
            } catch (PDOException $e) {
                // On ne renvoie jamais le message d'erreur SQL brut au client (sécurité)
                error_log('Erreur connexion DB: ' . $e->getMessage());
                throw new PDOException('Connexion à la base de données impossible.');
            }
        }

        return self::$instance;
    }
}

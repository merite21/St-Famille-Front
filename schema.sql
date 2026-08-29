-- =====================================================================
-- Hôpital Sainte Famille — Schéma de base de données V1
-- Moteur : MySQL 8.0+ (InnoDB, utf8mb4)
-- Généré à partir du cahier des charges v1.1, section 12
-- =====================================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ---------------------------------------------------------------------
-- 1. UTILISATEURS, ROLES, PERMISSIONS
-- ---------------------------------------------------------------------

CREATE TABLE roles (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nom             VARCHAR(50)  NOT NULL UNIQUE,        -- ex: receptionniste, caissier, medecin, infirmier_responsable, infirmier, administrateur
    description     VARCHAR(255) NULL,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE permissions (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    code            VARCHAR(100) NOT NULL UNIQUE,        -- ex: patients.create, soins.attribuer
    description     VARCHAR(255) NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE role_permissions (
    role_id         INT UNSIGNED NOT NULL,
    permission_id   INT UNSIGNED NOT NULL,
    PRIMARY KEY (role_id, permission_id),
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
    FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE users (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    role_id         INT UNSIGNED NOT NULL,
    matricule       VARCHAR(30)  NOT NULL UNIQUE,
    nom             VARCHAR(100) NOT NULL,
    prenom          VARCHAR(100) NOT NULL,
    email           VARCHAR(150) NULL UNIQUE,
    telephone       VARCHAR(30)  NULL,
    password_hash   VARCHAR(255) NOT NULL,
    actif           TINYINT(1)   NOT NULL DEFAULT 1,
    derniere_connexion DATETIME NULL,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES roles(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tokens de rafraîchissement (JWT refresh) — permet logout / révocation
CREATE TABLE auth_tokens (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id         INT UNSIGNED NOT NULL,
    refresh_token   VARCHAR(255) NOT NULL UNIQUE,
    expires_at      DATETIME NOT NULL,
    revoked         TINYINT(1) NOT NULL DEFAULT 0,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------
-- 2. PATIENTS, DOSSIERS
-- ---------------------------------------------------------------------

CREATE TABLE patients (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    numero_dossier  VARCHAR(30) NOT NULL UNIQUE,          -- identifiant unique métier (ex: SF-2026-00001)
    nom             VARCHAR(100) NOT NULL,
    prenom          VARCHAR(100) NOT NULL,
    date_naissance  DATE NULL,
    sexe            ENUM('M','F') NULL,
    telephone       VARCHAR(30) NULL,
    adresse         VARCHAR(255) NULL,
    contact_urgence VARCHAR(150) NULL,
    created_by      INT UNSIGNED NULL,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id),
    INDEX idx_patients_nom (nom, prenom)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Dossier = épisode de prise en charge (un patient peut avoir plusieurs passages)
CREATE TABLE dossiers (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    patient_id      INT UNSIGNED NOT NULL,
    statut          ENUM('ouvert','en_cours','cloture') NOT NULL DEFAULT 'ouvert',
    motif           VARCHAR(255) NULL,
    ouvert_par      INT UNSIGNED NULL,
    ouvert_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    cloture_at      DATETIME NULL,
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE,
    FOREIGN KEY (ouvert_par) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE constantes (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    dossier_id      INT UNSIGNED NOT NULL,
    temperature     DECIMAL(4,1) NULL,          -- en °C
    tension_systolique  SMALLINT UNSIGNED NULL,
    tension_diastolique SMALLINT UNSIGNED NULL,
    pouls           SMALLINT UNSIGNED NULL,
    poids           DECIMAL(5,2) NULL,          -- en kg
    taille          DECIMAL(5,2) NULL,          -- en cm
    saturation_o2   TINYINT UNSIGNED NULL,      -- en %
    saisi_par       INT UNSIGNED NULL,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (dossier_id) REFERENCES dossiers(id) ON DELETE CASCADE,
    FOREIGN KEY (saisi_par) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------
-- 3. PAIEMENT / PRESTATIONS
-- ---------------------------------------------------------------------

CREATE TABLE prestations (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    code            VARCHAR(30) NOT NULL UNIQUE,
    libelle         VARCHAR(150) NOT NULL,
    montant_fcfa    DECIMAL(10,0) NOT NULL,      -- FCFA n'a pas de décimales
    actif           TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE paiements (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    dossier_id      INT UNSIGNED NOT NULL,
    prestation_id   INT UNSIGNED NOT NULL,
    montant_fcfa    DECIMAL(10,0) NOT NULL,
    statut          ENUM('en_attente','confirme','annule','rembourse') NOT NULL DEFAULT 'en_attente',
    reference_externe VARCHAR(100) NULL,         -- référence dans le logiciel de caisse existant
    demande_par     INT UNSIGNED NULL,
    confirme_par    INT UNSIGNED NULL,
    demande_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    confirme_at     DATETIME NULL,
    FOREIGN KEY (dossier_id) REFERENCES dossiers(id) ON DELETE CASCADE,
    FOREIGN KEY (prestation_id) REFERENCES prestations(id),
    FOREIGN KEY (demande_par) REFERENCES users(id),
    FOREIGN KEY (confirme_par) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------
-- 4. FILE D'ATTENTE
-- ---------------------------------------------------------------------

CREATE TABLE file_attente (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    dossier_id      INT UNSIGNED NOT NULL,
    medecin_id      INT UNSIGNED NULL,           -- attribution éventuelle
    priorite        ENUM('normale','urgente') NOT NULL DEFAULT 'normale',
    statut          ENUM('en_attente','appele','en_consultation','termine','annule') NOT NULL DEFAULT 'en_attente',
    position        INT UNSIGNED NULL,
    entree_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    appele_at       DATETIME NULL,
    termine_at      DATETIME NULL,
    FOREIGN KEY (dossier_id) REFERENCES dossiers(id) ON DELETE CASCADE,
    FOREIGN KEY (medecin_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------
-- 5. CONSULTATIONS
-- ---------------------------------------------------------------------

CREATE TABLE consultations (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    dossier_id      INT UNSIGNED NOT NULL,
    medecin_id      INT UNSIGNED NOT NULL,
    motif           VARCHAR(255) NULL,
    observations    TEXT NULL,
    diagnostic      TEXT NULL,
    orientation     ENUM('sans_soins','avec_soins','autre') NOT NULL DEFAULT 'sans_soins',
    debut_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fin_at          DATETIME NULL,
    FOREIGN KEY (dossier_id) REFERENCES dossiers(id) ON DELETE CASCADE,
    FOREIGN KEY (medecin_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------
-- 6. SOINS INFIRMIERS (section 8.6)
-- ---------------------------------------------------------------------

CREATE TABLE types_soins (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    libelle         VARCHAR(150) NOT NULL UNIQUE,   -- injection, pansement, perfusion...
    actif           TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE salles_soins (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nom             VARCHAR(100) NOT NULL UNIQUE,   -- "Salle de soins 1"
    disponible      TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Demande créée par le médecin (8.6.1)
CREATE TABLE demandes_soins (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    dossier_id      INT UNSIGNED NOT NULL,
    consultation_id INT UNSIGNED NULL,
    type_soin_id    INT UNSIGNED NOT NULL,
    medecin_id      INT UNSIGNED NOT NULL,
    priorite        ENUM('normale','urgente') NOT NULL DEFAULT 'normale',
    instructions    TEXT NULL,
    statut          ENUM('en_attente','attribue','en_cours','termine','reporte','annule','patient_absent')
                    NOT NULL DEFAULT 'en_attente',
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (dossier_id) REFERENCES dossiers(id) ON DELETE CASCADE,
    FOREIGN KEY (consultation_id) REFERENCES consultations(id),
    FOREIGN KEY (type_soin_id) REFERENCES types_soins(id),
    FOREIGN KEY (medecin_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Attribution par l'infirmier responsable (8.6.2) — attribution ≠ médecin, cf. règle 8.6.5
CREATE TABLE attributions_soins (
    id                  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    demande_soin_id     INT UNSIGNED NOT NULL,
    infirmier_id        INT UNSIGNED NOT NULL,
    salle_soin_id       INT UNSIGNED NULL,
    attribue_par        INT UNSIGNED NOT NULL,       -- infirmier responsable / utilisateur habilité
    attribue_at         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (demande_soin_id) REFERENCES demandes_soins(id) ON DELETE CASCADE,
    FOREIGN KEY (infirmier_id) REFERENCES users(id),
    FOREIGN KEY (salle_soin_id) REFERENCES salles_soins(id),
    FOREIGN KEY (attribue_par) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Réalisation et validation du soin (8.6.3 / 8.6.4)
CREATE TABLE soins (
    id                  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    attribution_id      INT UNSIGNED NOT NULL,
    heure_soin          DATETIME NULL,
    soin_realise         TEXT NULL,
    observations        TEXT NULL,
    constantes_id        INT UNSIGNED NULL,          -- constantes relevées pendant le soin, si applicable
    incident             TEXT NULL,
    commentaire          TEXT NULL,
    valide               TINYINT(1) NOT NULL DEFAULT 0,
    valide_par           INT UNSIGNED NULL,
    valide_at            DATETIME NULL,
    FOREIGN KEY (attribution_id) REFERENCES attributions_soins(id) ON DELETE CASCADE,
    FOREIGN KEY (constantes_id) REFERENCES constantes(id),
    FOREIGN KEY (valide_par) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------
-- 7. GARDES / PLANNINGS (8.7, 8.8)
-- ---------------------------------------------------------------------

CREATE TABLE plannings (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id         INT UNSIGNED NOT NULL,          -- médecin ou infirmier
    date_debut      DATETIME NOT NULL,
    date_fin        DATETIME NOT NULL,
    service         VARCHAR(100) NULL,
    created_by      INT UNSIGNED NULL,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(id),
    INDEX idx_plannings_user_periode (user_id, date_debut, date_fin)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE gardes (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id         INT UNSIGNED NOT NULL,
    date_garde      DATE NOT NULL,
    type_garde      ENUM('jour','nuit','24h') NOT NULL DEFAULT 'jour',
    statut          ENUM('planifiee','confirmee','remplacee','annulee') NOT NULL DEFAULT 'planifiee',
    remplace_par    INT UNSIGNED NULL,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (remplace_par) REFERENCES users(id),
    UNIQUE KEY uq_garde_user_date_type (user_id, date_garde, type_garde)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------
-- 8. NOTIFICATIONS & AUDIT
-- ---------------------------------------------------------------------

CREATE TABLE notifications (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id         INT UNSIGNED NOT NULL,          -- destinataire
    type            VARCHAR(50) NOT NULL,           -- nouveau_patient, paiement_confirme, changement_statut, planning_modifie...
    contenu         VARCHAR(255) NOT NULL,
    lien_ressource  VARCHAR(255) NULL,               -- ex: /demandes-soins/12
    lu              TINYINT(1) NOT NULL DEFAULT 0,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE audit_logs (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id         INT UNSIGNED NULL,
    action          VARCHAR(100) NOT NULL,           -- ex: patients.update, paiements.confirmer
    entite          VARCHAR(50)  NOT NULL,           -- ex: patients, dossiers, paiements
    entite_id       INT UNSIGNED NULL,
    details         JSON NULL,
    ip_address      VARCHAR(45) NULL,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;

-- ---------------------------------------------------------------------
-- Données de référence minimales pour démarrer
-- ---------------------------------------------------------------------

INSERT INTO roles (nom, description) VALUES
    ('administrateur', 'Accès complet à la configuration et à la supervision'),
    ('receptionniste', 'Accueil, création des dossiers, constantes, envoi vers paiement'),
    ('caissier', 'Gestion des paiements'),
    ('medecin', 'Consultations et demandes de soins'),
    ('infirmier_responsable', 'Attribution des soins'),
    ('infirmier', 'Réalisation des soins attribués');

INSERT INTO prestations (code, libelle, montant_fcfa) VALUES
    ('CONSULT_GEN', 'Consultation générale', 7000);

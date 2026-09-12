-- Se ejecuta automáticamente cuando el contenedor de Postgres
-- arranca por primera vez (directorio docker-entrypoint-initdb.d)

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE IF NOT EXISTS users (
    id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    email         VARCHAR(255) NOT NULL UNIQUE,
    password_hash TEXT         NOT NULL,
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- Índice sobre email para logins rápidos
CREATE INDEX IF NOT EXISTS idx_users_email ON users (email);
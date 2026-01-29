-- Roles de sistema
CREATE ROLE anon NOLOGIN;
CREATE ROLE authenticated NOLOGIN;
CREATE ROLE service_role NOLOGIN;
CREATE ROLE supabase_admin WITH LOGIN PASSWORD 'postgres' SUPERUSER;
CREATE ROLE supabase_auth_admin WITH LOGIN PASSWORD 'postgres' NOINHERIT CREATEDB CREATEROLE;
CREATE ROLE supabase_storage_admin WITH LOGIN PASSWORD 'postgres' NOINHERIT CREATEDB CREATEROLE;
CREATE ROLE supabase_replication_admin WITH LOGIN PASSWORD 'postgres' NOINHERIT CREATEDB CREATEROLE;

-- Permisos básicos
GRANT ALL PRIVILEGES ON DATABASE postgres TO supabase_admin;
GRANT ALL PRIVILEGES ON DATABASE postgres TO supabase_auth_admin;
GRANT ALL PRIVILEGES ON DATABASE postgres TO supabase_storage_admin;

CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS storage;
CREATE SCHEMA IF NOT EXISTS realtime;
CREATE SCHEMA IF NOT EXISTS _realtime;

-- Roles necesarios adicionales (idempotentes)
CREATE ROLE IF NOT EXISTS anon NOLOGIN;
CREATE ROLE IF NOT EXISTS authenticated NOLOGIN;
CREATE ROLE IF NOT EXISTS service_role NOLOGIN;
CREATE ROLE IF NOT EXISTS supabase_admin NOLOGIN CREATEROLE CREATEDB REPLICATION BYPASSRLS;
CREATE ROLE IF NOT EXISTS supabase_auth_admin NOLOGIN NOINHERIT CREATEROLE;
CREATE ROLE IF NOT EXISTS supabase_storage_admin NOLOGIN NOINHERIT CREATEROLE;
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'postgres') THEN
    CREATE ROLE postgres NOLOGIN;
  END IF;
END$$;

-- Grants básicos adicionales
GRANT USAGE ON SCHEMA public TO postgres, anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO postgres, anon, authenticated, service_role;

-- 01_create_databases.sql
-- Creates 3 tenant databases if they don't exist
-- Called with: -v tenant=oraion

DO $$
DECLARE
   tenant_name TEXT := current_setting('tenant');
   db_name TEXT;
BEGIN
   db_name := tenant_name || '-analytics';
   IF NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = db_name) THEN
      EXECUTE format('CREATE DATABASE %I', db_name);
   END IF;

   db_name := tenant_name || '-ai';
   IF NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = db_name) THEN
      EXECUTE format('CREATE DATABASE %I', db_name);
   END IF;

   db_name := tenant_name || '-application';
   IF NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = db_name) THEN
      EXECUTE format('CREATE DATABASE %I', db_name);
   END IF;
END $$;
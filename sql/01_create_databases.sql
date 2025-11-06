-- 01_create_databases.sql
-- Creates 3 tenant databases if they don't exist
-- Called with: -v tenant=oraion

DO $$
DECLARE
   db_name TEXT;
BEGIN
   -- analytics
   db_name := :'tenant' || '-analytics';
   IF NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = db_name) THEN
      EXECUTE 'CREATE DATABASE "' || db_name || '"';
   END IF;

   -- ai
   db_name := :'tenant' || '-ai';
   IF NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = db_name) THEN
      EXECUTE 'CREATE DATABASE "' || db_name || '"';
   END IF;

   -- application
   db_name := :'tenant' || '-application';
   IF NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = db_name) THEN
      EXECUTE 'CREATE DATABASE "' || db_name || '"';
   END IF;
END $$;
-- 01_create_databases.sql
-- Create 3 tenant databases if they do not exist

DO $$
BEGIN
   IF NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = :'tenant' || '-analytics') THEN
      CREATE DATABASE :"tenant-analytics";
   END IF;

   IF NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = :'tenant' || '-ai') THEN
      CREATE DATABASE :"tenant-ai";
   END IF;

   IF NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = :'tenant' || '-application') THEN
      CREATE DATABASE :"tenant-application";
   END IF;
END $$;
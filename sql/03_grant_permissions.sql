-- 03_grant_permissions.sql
-- Connects to correct DB, creates local role, grants access
-- Called with: -v tenant=oraion -v suffix=analytics

-- analytics DB
\c :"tenant"-analytics
DO $$
BEGIN
   IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = :'tenant' || '-' || :'suffix') THEN
      CREATE ROLE :"tenant-suffix";
   END IF;
   GRANT ALL ON DATABASE :"tenant"-analytics TO :"tenant-suffix";
   ALTER DEFAULT PRIVILEGES IN SCHEMA public, staging, processed, reporting
         GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO :"tenant-suffix";
END $$;

-- ai DB
\c :"tenant"-ai
DO $$
BEGIN
   IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = :'tenant' || '-' || :'suffix') THEN
      CREATE ROLE :"tenant-suffix";
   END IF;
   GRANT ALL ON DATABASE :"tenant"-ai TO :"tenant-suffix";
   ALTER DEFAULT PRIVILEGES IN SCHEMA public
         GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO :"tenant-suffix";
END $$;

-- application DB
\c :"tenant"-application
DO $$
BEGIN
   IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = :'tenant' || '-' || :'suffix') THEN
      CREATE ROLE :"tenant-suffix";
   END IF;
   GRANT ALL ON DATABASE :"tenant"-application TO :"tenant-suffix";
   ALTER DEFAULT PRIVILEGES IN SCHEMA public
         GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO :"tenant-suffix";
END $$;
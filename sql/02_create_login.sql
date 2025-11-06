-- 02_create_login.sql
-- Creates LOGIN role in the *postgres* DB
-- Called with: -v tenant=oraion -v suffix=analytics -v password="..."

DO $$
BEGIN
   IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = :'tenant' || '-' || :'suffix') THEN
      EXECUTE format(
         'CREATE ROLE %I WITH LOGIN PASSWORD %L',
         :'tenant' || '-' || :'suffix',
         :'password'
      );
   END IF;
END $$;
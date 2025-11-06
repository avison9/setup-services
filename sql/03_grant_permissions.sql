-- 03_grant_permissions.sql
-- Idempotent grants per DB
-- Called with: -v tenant=oraion -v suffix=analytics

\echo Applying grants for tenant :'tenant' / suffix :'suffix'

-- ANALYTICS
\if :'suffix' = 'analytics'
\connect :"tenant"-analytics

SELECT format('CREATE ROLE %I', :'tenant' || '-' || :'suffix')
WHERE NOT EXISTS (
  SELECT 1 FROM pg_roles WHERE rolname = :'tenant' || '-' || :'suffix'
)\gexec

GRANT ALL ON DATABASE :"tenant"-analytics TO :"tenant"-:"suffix";

ALTER DEFAULT PRIVILEGES IN SCHEMA public, staging, processed, reporting
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO :"tenant"-:"suffix";
\endif


-- AI
\if :'suffix' = 'ai'
\connect :"tenant"-ai

SELECT format('CREATE ROLE %I', :'tenant' || '-' || :'suffix')
WHERE NOT EXISTS (
  SELECT 1 FROM pg_roles WHERE rolname = :'tenant' || '-' || :'suffix'
)\gexec

GRANT ALL ON DATABASE :"tenant"-ai TO :"tenant"-:"suffix";

ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO :"tenant"-:"suffix";
\endif


-- APPLICATION
\if :'suffix' = 'application'
\connect :"tenant"-application

SELECT format('CREATE ROLE %I', :'tenant' || '-' || :'suffix')
WHERE NOT EXISTS (
  SELECT 1 FROM pg_roles WHERE rolname = :'tenant' || '-' || :'suffix'
)\gexec

GRANT ALL ON DATABASE :"tenant"-application TO :"tenant"-:"suffix";

ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO :"tenant"-:"suffix";
\endif

\echo Done granting permissions for :'tenant'-:'suffix'

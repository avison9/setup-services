-- 03_grant_permissions.sql
-- Grants permissions to tenant-specific roles
-- Called with: -v tenant=oraion -v suffix=analytics

\echo === Granting permissions for tenant :'tenant' / suffix :'suffix' ===

-- ──────────────────────────────────────────────────────────────
-- ANALYTICS
-- ──────────────────────────────────────────────────────────────
\if :'suffix' = 'analytics'
\connect :"tenant"-analytics

-- Create role if missing
SELECT format('CREATE ROLE %I', :'tenant' || '-' || :'suffix')
WHERE NOT EXISTS (
  SELECT 1 FROM pg_roles WHERE rolname = :'tenant' || '-' || :'suffix'
)\gexec

-- Grant database privileges
SELECT format('GRANT ALL ON DATABASE %I TO %I',
  :'tenant' || '-analytics',
  :'tenant' || '-' || :'suffix'
)\gexec

-- Default privileges in analytics schemas
ALTER DEFAULT PRIVILEGES IN SCHEMA public, staging, processed, reporting
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO :"tenant"-:"suffix";
\endif


-- ──────────────────────────────────────────────────────────────
-- AI
-- ──────────────────────────────────────────────────────────────
\if :'suffix' = 'ai'
\connect :"tenant"-ai

SELECT format('CREATE ROLE %I', :'tenant' || '-' || :'suffix')
WHERE NOT EXISTS (
  SELECT 1 FROM pg_roles WHERE rolname = :'tenant' || '-' || :'suffix'
)\gexec

SELECT format('GRANT ALL ON DATABASE %I TO %I',
  :'tenant' || '-ai',
  :'tenant' || '-' || :'suffix'
)\gexec

ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO :"tenant"-:"suffix";
\endif


-- ──────────────────────────────────────────────────────────────
-- APPLICATION
-- ──────────────────────────────────────────────────────────────
\if :'suffix' = 'application'
\connect :"tenant"-application

SELECT format('CREATE ROLE %I', :'tenant' || '-' || :'suffix')
WHERE NOT EXISTS (
  SELECT 1 FROM pg_roles WHERE rolname = :'tenant' || '-' || :'suffix'
)\gexec

SELECT format('GRANT ALL ON DATABASE %I TO %I',
  :'tenant' || '-application',
  :'tenant' || '-' || :'suffix'
)\gexec

ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO :"tenant"-:"suffix";
\endif

\echo === Completed grants for :'tenant'-:'suffix' ===

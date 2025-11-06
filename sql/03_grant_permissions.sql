-- 03_grant_permissions.sql
-- Idempotent grants per DB
-- Called with: -v tenant=oraion -v suffix=analytics

\echo Applying grants for tenant :'tenant' / suffix :'suffix'

-- Set boolean flags based on suffix
\set is_analytics 0
\set is_ai 0
\set is_application 0
\if :'suffix' = 'analytics'
    \set is_analytics 1
\elif :'suffix' = 'ai'
    \set is_ai 1
\elif :'suffix' = 'application'
    \set is_application 1
\endif

-- ANALYTICS
\if :is_analytics
    \connect :"tenant"-analytics
    SELECT format('CREATE ROLE %I', :'tenant' || '_' || :'suffix')
    WHERE NOT EXISTS (
      SELECT 1 FROM pg_roles WHERE rolname = :'tenant' || '_' || :'suffix'
    ) \gexec

    GRANT ALL ON DATABASE :"tenant"-analytics TO :"tenant"_"suffix";
    ALTER DEFAULT PRIVILEGES IN SCHEMA public, raw, dwh, data_access_layer
      GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO :"tenant"_"suffix";
\endif

-- AI
\if :is_ai
    \connect :"tenant"-ai
    SELECT format('CREATE ROLE %I', :'tenant' || '_' || :'suffix')
    WHERE NOT EXISTS (
      SELECT 1 FROM pg_roles WHERE rolname = :'tenant' || '_' || :'suffix'
    ) \gexec

    GRANT ALL ON DATABASE :"tenant"-ai TO :"tenant"_"suffix";
    ALTER DEFAULT PRIVILEGES IN SCHEMA public
      GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO :"tenant"_"suffix";
\endif

-- APPLICATION
\if :is_application
    \connect :"tenant"-application
    SELECT format('CREATE ROLE %I', :'tenant' || '_' || :'suffix')
    WHERE NOT EXISTS (
      SELECT 1 FROM pg_roles WHERE rolname = :'tenant' || '_' || :'suffix'
    ) \gexec

    GRANT ALL ON DATABASE :"tenant"-application TO :"tenant"_"suffix";
    ALTER DEFAULT PRIVILEGES IN SCHEMA public
      GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO :"tenant"_"suffix";
\endif

\echo Done granting permissions for :'tenant'_:'suffix'

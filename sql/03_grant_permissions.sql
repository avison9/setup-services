-- 03_grant_permissions.sql
-- Idempotent grants per DB
-- Call: psql -v tenant=oraion -v suffix=analytics -f ...

\echo Applying grants for tenant :'tenant' / suffix :'suffix'

-- ------------------------------------------------------------------
-- Set **boolean** flags (true / false) – this is the ONLY way \if works
-- ------------------------------------------------------------------
-- Set default
\set is_analytics false
\set is_ai false
\set is_application false

-- Use SQL to determine which one is true
SELECT 
    CASE :'suffix'
        WHEN 'analytics' THEN true
        WHEN 'ai' THEN false
        ELSE false
    END as is_analytics,
    CASE :'suffix'
        WHEN 'ai' THEN true
        ELSE false
    END as is_ai,
    CASE :'suffix'
        WHEN 'application' THEN true
        ELSE false
    END as is_application
\gset


-- ------------------------------------------------------------------
-- ANALYTICS block
-- ------------------------------------------------------------------
\if :is_analytics
    \connect ":tenant-analytics"
    

    -- create role if missing
    SELECT format('CREATE ROLE %I', :'tenant' || '_analytics')
    WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = :'tenant' || '_analytics')
    \gexec

    GRANT ALL ON DATABASE :"tenant"_analytics TO :"tenant"_analytics;

    ALTER DEFAULT PRIVILEGES IN SCHEMA public, raw, dwh, data_access_layer
        GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO :"tenant"_analytics;
\endif

-- ------------------------------------------------------------------
-- AI block
-- ------------------------------------------------------------------
\if :is_ai
    \connect ":tenant-ai"

    SELECT format('CREATE ROLE %I', :'tenant' || '_ai')
    WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = :'tenant' || '_ai')
    \gexec

    GRANT ALL ON DATABASE :"tenant"_ai TO :"tenant"_ai;

    ALTER DEFAULT PRIVILEGES IN SCHEMA public
        GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO :"tenant"_ai;
\endif

-- ------------------------------------------------------------------
-- APPLICATION block
-- ------------------------------------------------------------------
\if :is_application
    \connect ":tenant-application"

    SELECT format('CREATE ROLE %I', :'tenant' || '_application')
    WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = :'tenant' || '_application')
    \gexec

    GRANT ALL ON DATABASE :"tenant"_application TO :"tenant"_application;

    ALTER DEFAULT PRIVILEGES IN SCHEMA public
        GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO :"tenant"_application;
\endif

\echo Done granting permissions for :'tenant'_:'suffix'


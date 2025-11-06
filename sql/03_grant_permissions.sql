-- 03_grant_permissions.sql
-- Idempotent grants per DB
-- Called with: -v tenant=oraion -v suffix=analytics

\echo Applying grants for tenant :'tenant' / suffix :'suffix'

-- Reset boolean flags
\set is_analytics false
\set is_ai false
\set is_application false

-- Set correct flag based on suffix
\if :suffix = analytics
    \set is_analytics true
\elif :suffix = ai
    \set is_ai true
\elif :suffix = application
    \set is_application true
\endif

-- ANALYTICS
\if :is_analytics
    \connect :"tenant"_analytics

    -- Create role if not exists
    SELECT format('CREATE ROLE %I', :'tenant' || '_analytics')
    WHERE NOT EXISTS (
        SELECT 1 FROM pg_roles WHERE rolname = :'tenant' || '_analytics'
    ) \gexec

    GRANT ALL ON DATABASE :"tenant"_analytics TO :"tenant"_analytics;

    ALTER DEFAULT PRIVILEGES IN SCHEMA public, raw, dwh, data_access_layer
        GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO :"tenant"_analytics;
\endif

-- AI
\if :is_ai
    \connect :"tenant"_ai

    SELECT format('CREATE ROLE %I', :'tenant' || '_ai')
    WHERE NOT EXISTS (
        SELECT 1 FROM pg_roles WHERE rolname = :'tenant' || '_ai'
    ) \gexec

    GRANT ALL ON DATABASE :"tenant"_ai TO :"tenant"_ai;

    ALTER DEFAULT PRIVILEGES IN SCHEMA public
        GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO :"tenant"_ai;
\endif

-- APPLICATION
\if :is_application
    \connect :"tenant"_application

    SELECT format('CREATE ROLE %I', :'tenant' || '_application')
    WHERE NOT EXISTS (
        SELECT 1 FROM pg_roles WHERE rolname = :'tenant' || '_application'
    ) \gexec

    GRANT ALL ON DATABASE :"tenant"_application TO :"tenant"_application;

    ALTER DEFAULT PRIVILEGES IN SCHEMA public
        GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO :"tenant"_application;
\endif

\echo Done granting permissions for :'tenant'_:'suffix'
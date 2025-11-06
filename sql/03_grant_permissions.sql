-- 03_grant_permissions.sql
-- Idempotent grants per DB
-- Call: psql -v tenant=oraion -v suffix=analytics -f ...

\echo Applying grants for tenant :'tenant' / suffix :'suffix'

-- ------------------------------------------------------------------
-- Set boolean flags (true / false) – only way \if works
-- ------------------------------------------------------------------
\set is_analytics false
\set is_ai false
\set is_application false

-- Determine which one is true
SELECT 
    CASE :'suffix'
        WHEN 'analytics' THEN true
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
    \connect :"tenant"_analytics

    -- build role name
    \set role_name :"tenant"_analytics

    -- create role if missing
    SELECT format('CREATE ROLE %I', :'role_name')
    WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = :'role_name')
    \gexec

    -- grant all privileges on current database
    SELECT format('GRANT ALL ON DATABASE %I TO %I', current_database(), :'role_name') \gexec

    -- grant default privileges on tables
    SELECT format(
        'ALTER DEFAULT PRIVILEGES IN SCHEMA public, raw, dwh, data_access_layer ' ||
        'GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO %I',
        :'role_name'
    ) \gexec
\endif

-- ------------------------------------------------------------------
-- AI block
-- ------------------------------------------------------------------
\if :is_ai
    \connect :"tenant"_ai

    \set role_name :"tenant"_ai

    SELECT format('CREATE ROLE %I', :'role_name')
    WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = :'role_name')
    \gexec

    SELECT format('GRANT ALL ON DATABASE %I TO %I', current_database(), :'role_name') \gexec

    SELECT format(
        'ALTER DEFAULT PRIVILEGES IN SCHEMA public ' ||
        'GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO %I',
        :'role_name'
    ) \gexec
\endif

-- ------------------------------------------------------------------
-- APPLICATION block
-- ------------------------------------------------------------------
\if :is_application
    \connect :"tenant"_application

    \set role_name :"tenant"_application

    SELECT format('CREATE ROLE %I', :'role_name')
    WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = :'role_name')
    \gexec

    SELECT format('GRANT ALL ON DATABASE %I TO %I', current_database(), :'role_name') \gexec

    SELECT format(
        'ALTER DEFAULT PRIVILEGES IN SCHEMA public ' ||
        'GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO %I',
        :'role_name'
    ) \gexec
\endif

\echo Done granting permissions for :'tenant'_:'suffix'

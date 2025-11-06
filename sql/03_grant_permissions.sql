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
-- Prepare full names
-- ------------------------------------------------------------------
-- dynamically build database and role names
SELECT :'tenant' || '_analytics' AS dbname \gset
SELECT :'tenant' || '_analytics' AS role_name \gset

-- ------------------------------------------------------------------
-- ANALYTICS block
-- ------------------------------------------------------------------
\if :is_analytics
    \connect :'dbname'

    -- create role if missing
    SELECT format('CREATE ROLE %I', :'role_name')
    WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = :'role_name')
    \gexec

    -- grant all privileges on database
    SELECT format('GRANT ALL ON DATABASE %I TO %I;', :'dbname', :'role_name') \gexec;

    -- grant default privileges on tables
    SELECT format(
        'ALTER DEFAULT PRIVILEGES IN SCHEMA public, raw, dwh, data_access_layer ' ||
        'GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO %I;',
        :'role_name'
    ) \gexec;
\endif

-- ------------------------------------------------------------------
-- AI block
-- ------------------------------------------------------------------
\if :is_ai
    \connect :'dbname'

    SELECT format('CREATE ROLE %I', :'role_name')
    WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = :'role_name')
    \gexec

    SELECT format('GRANT ALL ON DATABASE %I TO %I;', :'dbname', :'role_name') \gexec;

    SELECT format(
        'ALTER DEFAULT PRIVILEGES IN SCHEMA public ' ||
        'GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO %I;',
        :'role_name'
    ) \gexec;
\endif

-- ------------------------------------------------------------------
-- APPLICATION block
-- ------------------------------------------------------------------
\if :is_application
    \connect :'dbname'

    SELECT format('CREATE ROLE %I', :'role_name')
    WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = :'role_name')
    \gexec

    SELECT format('GRANT ALL ON DATABASE %I TO %I;', :'dbname', :'role_name') \gexec;

    SELECT format(
        'ALTER DEFAULT PRIVILEGES IN SCHEMA public ' ||
        'GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO %I;',
        :'role_name'
    ) \gexec;
\endif

\echo Done granting permissions for :'tenant'_:'suffix'

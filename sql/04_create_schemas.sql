-- ------------------------------------------------------------------
-- Schema creation – **only** for analytics
-- ------------------------------------------------------------------
-- Set default
\set is_analytics false

-- Determine if analytics
SELECT 
    CASE :'suffix'
        WHEN 'analytics' THEN true
        ELSE false
    END as is_analytics
\gset

\if :is_analytics
    -- dynamically build database and role names
    SELECT :'tenant' || '_analytics' AS dbname \gset
    SELECT :'tenant' || '_analytics' AS role_name \gset

    \connect :'dbname'

    CREATE SCHEMA IF NOT EXISTS raw;
    CREATE SCHEMA IF NOT EXISTS dwh;
    CREATE SCHEMA IF NOT EXISTS data_access_layer;

    -- search_path for admin and the analytics role
    SELECT format('ALTER ROLE %I SET search_path TO raw, dwh, data_access_layer, public', 'administrator') \gexec;
    SELECT format('ALTER ROLE %I SET search_path TO raw, dwh, data_access_layer, public', :'role_name') \gexec;
\endif

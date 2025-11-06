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
    -- full database and role names
    \set dbname :'tenant' || '_analytics'
    \set role_name :'tenant' || '_analytics'

    \connect :'dbname'

    CREATE SCHEMA IF NOT EXISTS raw;
    CREATE SCHEMA IF NOT EXISTS dwh;
    CREATE SCHEMA IF NOT EXISTS data_access_layer;

    -- search_path for admin and the analytics role
    SELECT format('ALTER ROLE %I SET search_path TO raw, dwh, data_access_layer, public', 'administrator') \gexec;
    SELECT format('ALTER ROLE %I SET search_path TO raw, dwh, data_access_layer, public', :'role_name') \gexec;
\endif

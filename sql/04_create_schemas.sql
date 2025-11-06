-- ------------------------------------------------------------------
-- Schema creation – **only** for analytics
-- ------------------------------------------------------------------
-- Set default
\set is_analytics false

-- Use SQL to determine which one is true
SELECT 
    CASE :'suffix'
        WHEN 'analytics' THEN true
        WHEN 'ai' THEN false
        ELSE false
    END as is_analytics
\gset

\if :is_analytics
    \connect :"tenant"_analytics

    CREATE SCHEMA IF NOT EXISTS raw;
    CREATE SCHEMA IF NOT EXISTS dwh;
    CREATE SCHEMA IF NOT EXISTS data_access_layer;

    -- search_path for admin and the analytics role
    SELECT format('ALTER ROLE %I SET search_path TO raw, dwh, data_access_layer, public', 'administrator') \gexec;
    SELECT format('ALTER ROLE %I SET search_path TO raw, dwh, data_access_layer, public', :'tenant' || '_analytics') \gexec;
\endif
-- Set boolean flags based on suffix
\set is_analytics false

\if :suffix = analytics
    \set is_analytics true
\endif

-- Schema creation only for analytics
\if :is_analytics
    \connect :"tenant"-analytics
    CREATE SCHEMA IF NOT EXISTS raw;
    CREATE SCHEMA IF NOT EXISTS dwh;
    CREATE SCHEMA IF NOT EXISTS data_access_layer;

    -- Set search_path for administrator and tenant-analytics
    SELECT format(
      'ALTER ROLE %I SET search_path TO raw, dwh, data_access_layer, public',
      'administrator'
    ) \gexec;

    SELECT format(
      'ALTER ROLE %I SET search_path TO raw, dwh, data_access_layer, public',
      :'tenant' || '_' || :'suffix'
    ) \gexec;
\endif
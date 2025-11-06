\if :suffix = analytics
\connect :"tenant"-analytics

CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS dwh;
CREATE SCHEMA IF NOT EXISTS data_access_layer;

-- Set search_path for administrator and tenant-analytics only
SELECT format(
  'ALTER ROLE %I SET search_path TO raw, dwh, data_access_layer, public',
  'administrator'
) \gexec;

SELECT format(
  'ALTER ROLE %I SET search_path TO raw, dwh, data_access_layer, public',
  :'tenant' || '-' || :'suffix'
) \gexec;
\endif

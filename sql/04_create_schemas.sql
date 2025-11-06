-- 04_create_schemas.sql
-- Creates base schemas and sets role search_path
-- Called with: -v tenant=oraion -v suffix=analytics

\echo Creating schemas and configuring role for :'tenant'-:'suffix'

CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS dwh;
CREATE SCHEMA IF NOT EXISTS data_access_layer;

ALTER ROLE :"tenant"-:"suffix" SET search_path TO raw, dwh, data_access_layer, public;

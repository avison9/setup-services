-- 04_create_schemas.sql
-- Must be run *inside* the target database
-- Called with: -v tenant=oraion -v suffix=analytics

CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS dwh;
CREATE SCHEMA IF NOT EXISTS data_access_layer;

ALTER ROLE :"tenant-suffix" SET search_path TO raw, dwh, data_access_layer, public;
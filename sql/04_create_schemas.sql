-- 04_create_schemas.sql
-- Creates schemas & sets search_path, safely

\echo Ensuring schemas and search path for :'tenant'-:'suffix'

CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS dwh;
CREATE SCHEMA IF NOT EXISTS data_access_layer;

ALTER ROLE :"tenant"-:"suffix" SET search_path TO raw, dwh, data_access_layer, public;

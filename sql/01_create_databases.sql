-- 01_create_databases.sql
-- Creates 3 tenant databases if they don't exist
-- Called with: -v tenant=oraion

\echo Creating databases for tenant :'tenant'

-- analytics
SELECT 'CREATE DATABASE "' || :'tenant' || '-analytics"' 
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = :'tenant' || '-analytics')\gexec

-- ai
SELECT 'CREATE DATABASE "' || :'tenant' || '-ai"' 
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = :'tenant' || '-ai')\gexec

-- application
SELECT 'CREATE DATABASE "' || :'tenant' || '-application"' 
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = :'tenant' || '-application')\gexec

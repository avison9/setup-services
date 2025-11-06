-- 01_create_databases.sql
-- Idempotent database creation

\echo Creating databases for tenant :'tenant'

SELECT format('CREATE DATABASE "%I-analytics"', :'tenant')
WHERE NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = :'tenant' || '-analytics')\gexec

SELECT format('CREATE DATABASE "%I-ai"', :'tenant')
WHERE NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = :'tenant' || '-ai')\gexec

SELECT format('CREATE DATABASE "%I-application"', :'tenant')
WHERE NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = :'tenant' || '-application')\gexec

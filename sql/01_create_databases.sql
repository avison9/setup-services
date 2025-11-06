-- 01_create_databases.sql
-- Idempotent database creation

-- \echo Creating databases for tenant :'tenant'

-- SELECT format('CREATE DATABASE "%I-analytics"', :'tenant')
-- WHERE NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = :'tenant' || '-analytics')\gexec

-- SELECT format('CREATE DATABASE "%I-ai"', :'tenant')
-- WHERE NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = :'tenant' || '-ai')\gexec

-- SELECT format('CREATE DATABASE "%I-application"', :'tenant')
-- WHERE NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = :'tenant' || '-application')\gexec


\echo Creating databases for tenant :'tenant'

-- Analytics database
SELECT format('CREATE DATABASE %I', :'tenant' || '_analytics')
WHERE NOT EXISTS (
    SELECT 1 FROM pg_database WHERE datname = :'tenant' || '_analytics'
)
\gexec

-- AI database
SELECT format('CREATE DATABASE %I', :'tenant' || '_ai')
WHERE NOT EXISTS (
    SELECT 1 FROM pg_database WHERE datname = :'tenant' || '_ai'
)
\gexec

-- Application database
SELECT format('CREATE DATABASE %I', :'tenant' || '_application')
WHERE NOT EXISTS (
    SELECT 1 FROM pg_database WHERE datname = :'tenant' || '_application'
)
\gexec

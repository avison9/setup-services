-- 02_create_login.sql
-- Idempotent role creation

\echo Creating login role for :'tenant'_:'suffix'

SELECT format(
  'CREATE ROLE %I WITH LOGIN PASSWORD %L',
  :'tenant' || '_' || :'suffix',
  :'password'
)
WHERE NOT EXISTS (
  SELECT 1 FROM pg_roles WHERE rolname = :'tenant' || '_' || :'suffix'
)\gexec

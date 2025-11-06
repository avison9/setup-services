-- 02_create_login.sql
-- Creates a login role if it doesn’t exist
-- Called with: -v tenant=oraion -v suffix=analytics -v password=somepass

\echo Creating login role for :'tenant'-:'suffix'

-- Create role if missing
SELECT format(
  'CREATE ROLE %I WITH LOGIN PASSWORD %L',
  :'tenant' || '-' || :'suffix',
  :'password'
)
WHERE NOT EXISTS (
  SELECT 1 FROM pg_roles WHERE rolname = :'tenant' || '-' || :'suffix'
)\gexec

DO $$
BEGIN
   IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = :'tenant' || '-' || :'suffix') THEN
      EXECUTE format(
         'CREATE ROLE %I WITH LOGIN PASSWORD %L',
         :'tenant' || '-' || :'suffix',
         :'password'
      );
   END IF;
END $$;
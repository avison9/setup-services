DO $$
BEGIN
   IF NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = :'tenant' || '-analytics') THEN
      EXECUTE 'CREATE DATABASE "' || :'tenant' || '-analytics"';
   END IF;

   IF NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = :'tenant' || '-ai') THEN
      EXECUTE 'CREATE DATABASE "' || :'tenant' || '-ai"';
   END IF;

   IF NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = :'tenant' || '-application') THEN
      EXECUTE 'CREATE DATABASE "' || :'tenant' || '-application"';
   END IF;
END $$;
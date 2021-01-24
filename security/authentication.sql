
-- Show the authentication configuration settings
-- https://www.postgresql.org/docs/13/auth-pg-hba-conf.html
select *
from pg_catalog.pg_hba_file_rules;

-- Show the contents of the external username mapping configuration file
-- NB there doesn't appear to be a system view to expose this configuration file more easily.
-- https://www.postgresql.org/docs/13/auth-username-maps.html
SELECT pg_read_file('pg_ident.conf');
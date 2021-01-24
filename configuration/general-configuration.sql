-- Retrives information about the installed version of postgres
-- https://www.postgresql.org/docs/13/app-pgconfig.html
select *
from pg_catalog.pg_config
;


-- Retrive just the version information
select version();


-- This view shows the runtime settings of the server.
-- https://www.postgresql.org/docs/13/view-pg-settings.html
select *
from pg_catalog.pg_settings
;


-- The view pg_file_settings provides a summary of the contents of the server's configuration file(s)
-- https://www.postgresql.org/docs/13/view-pg-file-settings.html
select *
from pg_catalog.pg_file_settings;
;
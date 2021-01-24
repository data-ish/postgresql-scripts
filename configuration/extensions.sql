-- List the extensions availble.
-- A new instance will usually show plpgsql only.
-- https://www.postgresql.org/docs/13/catalog-pg-extension.html
select *
from pg_catalog.pg_extension;


-- View available extensions on the system
-- https://www.postgresql.org/docs/13/view-pg-available-extensions.html
select *
from pg_catalog.pg_available_extensions;
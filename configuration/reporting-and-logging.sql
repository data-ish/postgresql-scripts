
-- https://www.postgresql.org/docs/13/runtime-config-logging.html

select *
from pg_settings
where category like 'Reporting%'
;

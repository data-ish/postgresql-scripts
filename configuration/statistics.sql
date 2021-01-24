
-- https://www.postgresql.org/docs/13/runtime-config-statistics.html

select *
from pg_settings
where category like 'Statistics%'
;



-- https://www.postgresql.org/docs/13/runtime-config-locks.html

select *
from pg_settings
where category like 'Lock%'
;
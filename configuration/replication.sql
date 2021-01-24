
-- https://www.postgresql.org/docs/13/runtime-config-replication.html

select *
from pg_settings
where category like 'Replication%'
;
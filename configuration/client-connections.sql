-- https://www.postgresql.org/docs/13/runtime-config-client.html
select *
from pg_settings
where category like 'Client%'
;
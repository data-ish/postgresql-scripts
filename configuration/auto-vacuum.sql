-- https://www.postgresql.org/docs/13/runtime-config-autovacuum.html
select *
from pg_settings
where category like 'Autovacuum%'
;
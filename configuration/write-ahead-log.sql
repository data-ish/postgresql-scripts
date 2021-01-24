
-- https://www.postgresql.org/docs/13/runtime-config-wal.html

select *
from pg_settings
where category like 'Write-Ahead%'
;

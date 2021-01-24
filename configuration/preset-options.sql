
-- https://www.postgresql.org/docs/13/runtime-config-preset.html

select *
from pg_settings
where category like 'Preset%'
;
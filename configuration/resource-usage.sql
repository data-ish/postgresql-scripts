
-- https://www.postgresql.org/docs/13/runtime-config-resource.html
-- https://www.postgresql.org/docs/13/view-pg-settings.html

select *
from pg_settings
where category like 'Resource Usage%'
;
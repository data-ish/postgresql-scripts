
-- https://www.postgresql.org/docs/13/runtime-config-resource.html
-- https://www.postgresql.org/docs/13/runtime-config-query.html

select *
from pg_settings
where category like 'Query%'
;
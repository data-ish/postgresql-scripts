select
    d.oid,
    d.datname as database_name,
    d.datacl,
    pg_catalog.pg_get_userbyid(d.datdba) as owner
from pg_catalog.pg_database as d
;
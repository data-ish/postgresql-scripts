-- Tables that do not have a Primary Key
with pk as (
    select
        n.nspname as schema_name,
        c.relname as table_name,
        c.oid,
        i.indexrelid
    from pg_class as c
    join pg_namespace as n on c.relnamespace = n.oid
    left join pg_index as i on i.indrelid = c.oid  and indisprimary
    where c.relkind = 'r'
    and n.nspname not in ('pg_catalog', 'pg_toast', 'information_schema')
)
select 
    pk.schema_name,
    pk.table_name,
    pk.oid
from pk 
where pk.indexrelid is null
-- Primary Key Names
-- An example of how you might start to write standards or policy tests over a database
select 
    n.nspname as schema_name,
    t.relname as table_name,
    pk.relname as index_name,
    case
        when pk.relname like concat(t.relname, '%') then true
        else false
    end as is_valid_pk_name
from pg_catalog.pg_class as t
join pg_catalog.pg_namespace as n on t.relnamespace = n.oid
join pg_catalog.pg_index as i on i.indrelid = t.oid and i.indisprimary
join pg_catalog.pg_class as pk on i.indexrelid = pk.oid
where t.relkind = 'r'


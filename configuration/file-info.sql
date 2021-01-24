--
-- https://www.postgresql.org/docs/13/storage-file-layout.html
-- https://www.postgresql.org/docs/13/catalog-pg-class.html
-- https://www.postgresql.org/docs/13/catalog-pg-tablespace.html

-- This shows the location of data files
show data_directory;



-- The default data directory structure
-- If configuration has been deliberately changed, or table spaces used then this will no longer be the case.
select
    d.datname as database_name,
    concat(s.setting,'/base/',d.oid) as data_directory,
    -- Other database data
    d.*
from pg_catalog.pg_database as d
cross join pg_catalog.pg_settings as s
where s.name = 'data_directory'
;



-- The location of data for each table.
-- One file per table, either in the default location, or in a tablespace if that has been specified instead
select
    n.nspname as schema_name,
    c.relname as table_name,
    case
        when c.reltablespace = 0 then concat(s.setting,'/base/',d.oid, '/', c.relfilenode)
        else  concat(s.setting, 'pg_tblspc', '/', t.oid, '/', d.oid, '/', c.relfilenode)
     end as table_data_file,
     pg_size_pretty( pg_relation_size(concat(n.nspname,'.',c.relname))) as table_data_size, -- NB this is the base table only, it doesn't include any extra indexes (which would be in seperate files).
    c.relfilenode,
    c.reltablespace
from pg_catalog.pg_class as c
join pg_catalog.pg_namespace as n on c.relnamespace = n.oid
left join pg_catalog.pg_tablespace as t on c.reltablespace = t.oid
cross join pg_catalog.pg_database as d 
cross join pg_catalog.pg_settings as s 
where d.datname = current_database()
and s.name = 'data_directory'
and c.relkind = 'r'
and n.nspname not in ('pg_catalog', 'information_schema') --ignore system tables
;


-- The location of data for each index.
-- One file per index, either in the default location, or in a tablespace if that has been specified instead
select
    n.nspname as schema_name,
    c.relname as index_name,
    case
        when c.reltablespace = 0 then concat(s.setting,'/base/',d.oid, '/', c.relfilenode)
        else  concat(s.setting, 'pg_tblspc', '/', t.oid, '/', d.oid, '/', c.relfilenode)
     end as table_data_file,
     pg_size_pretty( pg_relation_size(concat(n.nspname,'.',c.relname))) as table_data_size, -- NB this is the base table only, it doesn't include any extra indexes (which would be in seperate files).
    c.relfilenode,
    c.reltablespace
from pg_catalog.pg_class as c
join pg_catalog.pg_namespace as n on c.relnamespace = n.oid
left join pg_catalog.pg_tablespace as t on c.reltablespace = t.oid
cross join pg_catalog.pg_database as d 
cross join pg_catalog.pg_settings as s 
where d.datname = current_database()
and s.name = 'data_directory'
and c.relkind = 'i'
and n.nspname not in ('pg_catalog', 'information_schema', 'pg_toast') --ignore system tables
;


-- This shows file locations, of which one is the data_directory
-- https://www.postgresql.org/docs/13/view-pg-settings.html
select name, setting
from pg_settings
where category = 'File Locations'
;
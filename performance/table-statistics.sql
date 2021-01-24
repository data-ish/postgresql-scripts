
-- https://www.postgresql.org/docs/13/functions-admin.html#FUNCTIONS-ADMIN-DBOBJECT
-- https://www.postgresql.org/docs/13/monitoring-stats.html#MONITORING-PG-STAT-ALL-TABLES-VIEW

-- Get size of all databases
select d.datname as database_name,
    pg_size_pretty(pg_database_size(d.datname)) as database_size
from pg_catalog.pg_database as d
order by pg_database_size(d.datname) desc
;


-- Get size of tables, table indexes, the total size, and proprtion of the database
select
    n.nspname as schema_name,
    t.relname as table_name,
    pg_size_pretty(pg_table_size(concat(n.nspname,'.',t.relname))) as base_table_size,
    pg_size_pretty(pg_indexes_size(concat(n.nspname,'.',t.relname))) as indexes_size,
    pg_size_pretty(pg_total_relation_size(concat(n.nspname,'.',t.relname))) as total_size,
    round((pg_total_relation_size(concat(n.nspname,'.',t.relname))::numeric / pg_database_size(current_database()))*100,2) as percentage_of_database_size
from pg_catalog.pg_class as t
join pg_catalog.pg_namespace as n on t.relnamespace = n.oid
where t.relkind = 'r'
and n.nspname not in ('pg_catalog', 'pg_toast', 'information_schema')
order by percentage_of_database_size desc
;


-- Various system counters kept against each table
-- This query uses the pg_stat_user_tables view, there is also a pg_stat_all_tables view which shows system table information as well
-- https://www.postgresql.org/docs/13/monitoring-stats.html#MONITORING-PG-STAT-ALL-TABLES-VIEW
select
    t.relid,
    t.schemaname as schema_name,
    t.relname as table_name,
    pg_size_pretty(pg_table_size(t.relid)) as table_size,
    t.seq_scan,
    t.seq_tup_read,
    t.idx_scan,
    t.idx_tup_fetch,
    t.n_tup_ins,
    t.n_tup_upd,
    t.n_tup_del,
    t.n_tup_hot_upd,
    t.n_live_tup,
    t.n_dead_tup,
    t.n_mod_since_analyze,
    t.last_vacuum,
    t.last_autovacuum,
    t.last_analyze,
    t.last_autoanalyze,
    t.vacuum_count,
    t.autovacuum_count,
    t.analyze_count,
    t.autoanalyze_count
from pg_catalog.pg_stat_user_tables as t 
order by pg_table_size(relid)
;


-- Internal index tuple information
-- You probably don't need this
create extension if not exists pgstattuple;
select
    n.nspname as schema_name,
    t.relname as table_name,
    f.table_len,
    f.tuple_count,
    f.tuple_len,
    f.tuple_percent,
    f.dead_tuple_count,
    f.dead_tuple_len,
    f.dead_tuple_percent,
    f.free_space,
    f.free_percent
from pg_class as t 
join pg_namespace as n on t.relnamespace = n.oid
cross join lateral pgstattuple(t.oid) f
where t.relkind = 'r' --tables
and n.nspname not in ('pg_catalog', 'pg_toast', 'information_schema')
;

-- Some queries require the pg_stat_statements extension
create extension if not exists pg_stat_statements;


-- Show tables sorted by disk activity
select
    t.schemaname as schema_name,
    t.relname as table_name,
    t.relid,
    t.heap_blks_read,
    t.heap_blks_hit,
    case
        when t.heap_blks_read = 0 then 0
        else round(t.heap_blks_read::numeric / (t.heap_blks_read + t.heap_blks_hit)*100,2)
    end as cache_miss_percentage,
    case
        when t.heap_blks_read = 0 then 0
        else round(t.heap_blks_hit::numeric / (t.heap_blks_read + t.heap_blks_hit)*100,2)
    end as cache_hit_percentage,
    r.n_live_tup as number_rows
from pg_statio_user_tables as t
join pg_stat_user_tables as r on t.relid = r.relid
order by heap_blks_read desc
;


-- Show tables with no IO. Unused?
select
    t.schemaname as schema_name,
    t.relname as table_name,
    t.relid,
    r.n_live_tup as number_rows
from pg_statio_user_tables as t
join pg_stat_user_tables as r on t.relid = r.relid
where heap_blks_read = 0
and heap_blks_hit = 0
;


-- Show tables sorted by cache misses
select
    t.schemaname as schema_name,
    t.relname as table_name,
    t.relid,
    t.heap_blks_read,
    t.heap_blks_hit,
    case
        when t.heap_blks_read = 0 then 0
        else round(t.heap_blks_read::numeric / (t.heap_blks_read + t.heap_blks_hit)*100,2)
    end as cache_miss_percentage,
    case
        when t.heap_blks_read = 0 then 0
        else round(t.heap_blks_hit::numeric / (t.heap_blks_read + t.heap_blks_hit)*100,2)
    end as cache_hit_percentage,
    r.n_live_tup as number_rows
from pg_statio_user_tables as t
join pg_stat_user_tables as r on t.relid = r.relid
order by cache_hit_percentage asc
;


-- Temporary blocks written by queries.
select
    d.datname as database_name,
    u.usename as user_name,
    s.query,
    pg_size_pretty(s.temp_blks_read*8192) as temp_size_read,
    pg_size_pretty(s.temp_blks_written*8192) as temp_size_written,
    s.calls,
    s.rows,
    s.temp_blks_read,
    s.temp_blks_written
from pg_stat_statements as s
join pg_catalog.pg_database as d on s.dbid = d.oid
join pg_catalog.pg_user as u on s.userid = u.usesysid
order by (s.temp_blks_read + s.temp_blks_written) desc
;


-- Temporary files and blocks written by database
select
    d.datname as database_name,
    d.temp_files,
    pg_size_pretty(d.temp_bytes) as temp_size,
    d.temp_bytes
from pg_stat_database as d
where datname not in ('template0', 'template1')
order by temp_bytes desc
;


-- Statement time spent on IO
-- Requires that track_io_timing is enabled
-- select * from pg_settings where name = 'track_io_timing';
select
    d.datname as database_name,
    u.usename as user_name,
    s.query,
    (s.blk_read_time/1000)::bigint as blk_read_time_seconds,
    (s.blk_write_time/1000)::bigint as blk_write_time_seconds,
    s.calls,
    s.rows
from pg_stat_statements as s
join pg_catalog.pg_database as d on s.dbid = d.oid
join pg_catalog.pg_user as u on s.userid = u.usesysid
order by blk_write_time desc
;


-- Database time spent on IO
-- Requires that track_io_timing is enabled
-- select * from pg_settings where name = 'track_io_timing';
select
    d.datname as database_name,
    (d.blk_read_time/1000)::bigint as blk_read_time_seconds,
    (d.blk_write_time/1000)::bigint as blk_write_time_seconds,
    d.*
from pg_stat_database as d
where datname not in ('template0', 'template1')
;


-- Statio Monitoring Views

-- https://www.postgresql.org/docs/13/monitoring-stats.html#MONITORING-PG-STATIO-ALL-TABLES-VIEW
select * from pg_statio_user_tables;


-- https://www.postgresql.org/docs/13/monitoring-stats.html#MONITORING-PG-STATIO-ALL-INDEXES-VIEW
select * from pg_statio_user_indexes;


-- https://www.postgresql.org/docs/13/monitoring-stats.html#MONITORING-PG-STATIO-ALL-SEQUENCES-VIEW
select * from pg_statio_user_sequences;
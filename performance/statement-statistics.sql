
-- https://www.postgresql.org/docs/13/pgstatstatements.html

-- This requires pg_stat_statements enabled
-- This requires pg_stat_statements being placed in the postgresql.conf file shared libs 'expand
-- This also requires the extension being created

create extension if not exists pg_stat_statements;


-- Number of calls per database, shows which database has the most statements (queries) executed against it.
select
    d.datname as database_name,
    sum(calls) number_of_calls
from pg_stat_statements as s
join pg_catalog.pg_database as d on s.dbid = d.oid
group by d.datname
;


-- Total statement time per database, not neccessarily analogous to CPU time, but may be. Waiting on IO, or locks to be released would also feed into this statistic.
-- Lots of calls that are executed quickly are less likely to be an issue than a database with a high amount of time.
-- This is likely to be more relevant in diagnosing areas to target when looking for bottlenecks and performance issues
select
    d.datname as database_name,
    sum(total_time)::bigint/1000 total_time_seconds
from pg_stat_statements as s
join pg_catalog.pg_database as d on s.dbid = d.oid
group by d.datname
;


-- Total Buffer / Memory / IO by database
select
    d.datname as database_name,
    sum(shared_blks_hit) as pages_already_in_memory,
    sum(shared_blks_read) as pages_read_from_disk_into_memory,
    sum(shared_blks_dirtied) as pages_changed_in_memory,
    sum(shared_blks_written) as pages_evicted_from_memory_written_to_disk
from pg_stat_statements as s
join pg_catalog.pg_database as d on s.dbid = d.oid
group by d.datname
;


-- Total Local buffer by database
-- Local buffer used for temporary tables and indexes
-- https://www.postgresql.org/docs/13/sql-explain.html
select
    d.datname as database_name,
    sum(local_blks_hit) as pages_already_in_memory,
    sum(local_blks_read) as pages_read_from_disk_into_memory,
    sum(local_blks_dirtied) as pages_changed_in_memory,
    sum(local_blks_written) as pages_evicted_from_memory_written_to_disk
from pg_stat_statements as s
join pg_catalog.pg_database as d on s.dbid = d.oid
group by d.datname
;


-- Total Temp buffer by database
-- Temp buffer is used for short term operations (hashes, sorts, etc)
-- https://www.postgresql.org/docs/13/sql-explain.html
select
    d.datname as database_name,
    sum(temp_blks_read) as pages_read_from_disk_into_memory,
    sum(temp_blks_written) as pages_evicted_from_memory_written_to_disk
from pg_stat_statements as s
join pg_catalog.pg_database as d on s.dbid = d.oid
group by d.datname
;


-- Statstics per query / statement
-- Time is generally in milliseconds unless specified
select
    d.datname as database_name,
    s.query,
    sum(s.calls) as calls,
    sum(s.total_time)::bigint/1000 as total_time_seconds,
    sum(s.total_time) as total_time,
    min(s.min_time) as min_time,
    max(max_time) as max_time,
    sum(calls) / sum(total_time) as mean_time,
    |/sum(stddev_time^2) as stddev_time,
    sum("rows") as "rows",
    sum(shared_blks_hit) as shared_blks_hit,
    sum(shared_blks_read) as shared_blks_read,
    sum(shared_blks_dirtied) as shared_blks_dirtied,
    sum(shared_blks_written) as shared_blks_written,
    sum(local_blks_hit) as local_blks_hit,
    sum(local_blks_read) as local_blks_read,
    sum(local_blks_dirtied) as local_blks_dirtied,
    sum(local_blks_written) as local_blks_written,
    sum(temp_blks_read) as temp_blks_read,
    sum(temp_blks_written) as temp_blks_written,
    sum(blk_read_time) as blk_read_time,
    sum(blk_write_time) as blk_write_time
from public.pg_stat_statements as s
join pg_catalog.pg_database as d on s.dbid = d.oid
group by d.datname, s.query
order by total_time desc
;
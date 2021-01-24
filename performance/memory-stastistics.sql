
-- https://www.postgresql.org/docs/13/pgbuffercache.html
-- An extension is required to examine the memory buffer in detail
 create extension if not exists pg_buffercache;

-- One buffer = 8Kb unless this has been altered in source and recompiled
-- https://www.postgresql.org/docs/current/storage-page-layout.html

-- Although the buffer cache is shared at the instance level, the joins to objects only make sense intepreted in the context of a database.
--Apart from the first headline query, the rest are executed in the context of the current database.


-- Show the overall buffer cache stastics.
with sums as (
    select
        count(*) as total_buffer_pages,
        pg_size_pretty(count(*) * 8192) as total_buffer_size,
        sum(case when relfilenode is not null then 1 else 0 end) as used_buffer_pages,
        sum(case when relfilenode is not null then 0 else 1 end) as free_buffer_pages,
        sum(case when isdirty then 1 else 0 end ) as dirty_buffer_pages,
        sum(case when isdirty then 0 else 1 end ) as clean_buffer_pages,
        sum(case when pinning_backends > 0 then 1 else 0 end) as pinned_buffer_pages,
        sum(case when pinning_backends > 0 then 0 else 1 end) as unpinned_buffer_pages
    from pg_buffercache
)
select
    s.total_buffer_pages,
    s.total_buffer_size,
    s.used_buffer_pages,
    s.free_buffer_pages,
    s.dirty_buffer_pages,
    s.clean_buffer_pages,
    s.pinned_buffer_pages,
    s.unpinned_buffer_pages,
    pg_size_pretty(s.used_buffer_pages*8192) as used_buffer_size,
    pg_size_pretty(s.free_buffer_pages*8192) as free_buffer_size,
    pg_size_pretty(s.dirty_buffer_pages*8192) as dirty_buffer_size,
    pg_size_pretty(s.clean_buffer_pages*8192) as clean_buffer_size,
    pg_size_pretty(s.pinned_buffer_pages*8192) as pinned_buffer_size,
    pg_size_pretty(s.unpinned_buffer_pages*8192) as unpinned_buffer_size,
    round(s.used_buffer_pages / s.total_buffer_pages, 2) as used_buffer_percentage,
    round(s.dirty_buffer_pages / s.total_buffer_pages, 2) as dirty_buffer_percentage,
    round(s.pinned_buffer_pages / s.total_buffer_pages, 2) as pinned_buffer_percentage
from sums as s
;


-- Count of buffers per object
select
    n.nspname as schema_name,
    c.relname as object_name,
    count(*) * 8 as buffer_size_kb
from pg_buffercache as b
join pg_class as c on b.relfilenode = pg_relation_filenode(c.oid)
    and b.reldatabase in (0, (select oid from pg_database where datname = current_database()))
join pg_namespace as n on c.relnamespace = n.oid
where n.nspname not in ('pg_catalog', 'pg_toast')
group by n.nspname, c.relname
order by count(*) desc
;
  

-- Dirty buffers by object
-- The sum of this is the total amount of changed data waiting to be written to disk
select
    n.nspname as schema_name,
    c.relname as object_name,
    count(*) * 8 as buffer_size_kb
from pg_buffercache as b
join pg_class as c on b.relfilenode = pg_relation_filenode(c.oid)
    and b.reldatabase in (0, (select oid from pg_database where datname = current_database()))
join pg_namespace as n on c.relnamespace = n.oid
where b.isdirty
and n.nspname not in ('pg_catalog', 'pg_toast')
group by n.nspname, c.relname
order by count(*) desc
;


-- Get details of objects in the cache
-- includes what proportion of an object is in the cache (compared to left on disk)
-- includes what proportion of the entire cache is used by a particular object
select
    n.nspname as schema_name,
    c.relname as object_name,
    count(*) as buffered_pages,
    pg_size_pretty(count(*) * 8192) as buffered_size,
    round(100.0 * count(*) / ( select setting from pg_settings where name='shared_buffers')::integer,2) as percentage_of_shared_buffer,
    round(100.0*count(*)*8192 / pg_table_size(c.oid),1) as percentage_of_object
from pg_buffercache as b
join pg_class as c on b.relfilenode = c.relfilenode
join pg_namespace as n on c.relnamespace = n.oid
join pg_database as d on ( b.reldatabase =d.oid and d.datname = current_database())
--where n.nspname not in ('pg_catalog', 'pg_toast')
group by c.oid, c.relname, n.nspname
order by count(*) desc 
;


-- Unused blocks by object
-- These are candidates to be ejected from the cache (once cache is full)
select
    n.nspname as schema_name,
    c.relname as object_name,
    count(*) as buffered_pages,
    count(*) * 8 as buffer_size_kb
from pg_buffercache as b
join pg_class as c on b.relfilenode = pg_relation_filenode(c.oid)
    and b.reldatabase in (0, (select oid from pg_database where datname = current_database()))
join pg_namespace as n on c.relnamespace = n.oid
where pinning_backends = 0
and n.nspname not in ('pg_catalog', 'pg_toast')
group by n.nspname, c.relname
order by count(*) desc
;
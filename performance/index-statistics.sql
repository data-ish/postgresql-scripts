
-- Heavily used indexes
-- Order indexes by number of tuples that have been read from them
select
    t.schemaname as schema_name,
    t.relname as table_name,
    t.relid,
    i.indexrelname as index_name,
    i.indexrelid,
    i.idx_scan as index_scan,
    i.idx_tup_fetch as index_tuple_fetch,
    i.idx_tup_read as index_tuple_read,
    t.idx_scan as table_scan,
    t.idx_tup_fetch as table_tuple_fetch,
    t.n_tup_ins as table_tuples_inserted,
    t.n_tup_upd table_tuples_updated,
    t.n_tup_del as table_tuples_deleted,
    (t.n_tup_ins + t.n_tup_upd + t.n_tup_del) as total_write_rows
from pg_stat_user_tables as t
join pg_stat_user_indexes as i on t.relid = i.relid
order by i.idx_tup_read desc
;


-- Potentially Missing Indexes
select
    t.schemaname as schema_name,
    t.relname as table_name,
    t.n_live_tup as estimated_rows,
    seq_scan,
    idx_scan,
    (seq_scan + idx_scan) as accesses,
    round(100*(seq_scan::numeric / (seq_scan + idx_scan)),2) as seq_access_percent,
    round(100*(idx_scan::numeric / (seq_scan + idx_scan)),2) as idx_access_percent
from pg_stat_user_tables as t
where t.n_live_tup > 100 -- For very small tables it doesn't really matter how they are accessed
order by idx_access_percent asc
;


-- Possibly duplicated indexes
with duplicates as 
(
    select
        i1.indrelid,
        i1.indexrelid as this_index_id,
        i2.indexrelid as that_index_id,
        i1.indimmediate,
        i1.indisprimary,
        i1.indisunique,
        i1.indkey as this_index_keys,
        i2.indkey as that_index_keys
    from pg_index as i1
    join pg_index as i2 on i1.indrelid = i2.indrelid
    where i1.indexrelid != i2.indexrelid -- Don't count joins to the same index!
    and array_to_string(i2.indkey,'|') like concat(array_to_string(i1.indkey,'|'),'%') -- Do include indexes that start with the same keys, order is important.
)
select
    n.nspname as schema_name,
    t.relname as table_name,
    this.relname as this_index_name,
    that.relname as possible_duplcate_of,
    d.this_index_keys,
    d.that_index_keys
from duplicates as d
join pg_class as t on d.indrelid = t.oid
join pg_class as this on d.this_index_id = this.oid
join pg_class as that on d.that_index_id = that.oid
join pg_namespace as n on t.relnamespace = n.oid 
where n.nspname not in ('pg_toast', 'pg_catalog')
;


-- Potentially bad indexes
-- Where number of tuples (rows) read from an index is fewer than the number of rows written (inserted, updated & deleted) to a table, then the maintenance overhead of the index may be more than the benefit offered
with i as (
    select
        t.schemaname as schema_name,
        t.relname as table_name,
        t.relid,
        i.indexrelname as index_name,
        i.indexrelid,
        i.idx_scan as index_scan,
        i.idx_tup_fetch as index_tuple_fetch,
        i.idx_tup_read as index_tuple_read,
        t.idx_scan as table_scan,
        t.idx_tup_fetch as table_tuple_fetch,
        t.n_tup_ins as table_tuples_inserted,
        t.n_tup_upd table_tuples_updated,
        t.n_tup_del as table_tuples_deleted,
        (t.n_tup_ins + t.n_tup_upd + t.n_tup_del) as total_write_rows,
        case when t.n_tup_ins + t.n_tup_upd + t.n_tup_del < 1 then 1 else t.n_tup_ins + t.n_tup_upd + t.n_tup_del end as tww
    from pg_stat_user_tables as t
    join pg_stat_user_indexes as i on t.relid = i.relid
)
select
    i. schema_name,
    i.table_name,
    i.index_name,
--    i.relid,
--    i.indexrelid,
--    i.index_scan,
--    i.index_tuple_fetch,
--    i.table_scan,
--    i.table_tuple_fetch,
--    i.table_tuples_inserted,
--    i.table_tuples_updated,
--    i.table_tuples_deleted,
    i.index_tuple_read,
    i.total_write_rows,
    round(i.index_tuple_read::numeric / tww,2) as index_read_to_table_write_ratio
from i 
order by index_read_to_table_write_ratio asc
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
where t.relkind = 'i' --indexes
and n.nspname not in ('pg_catalog', 'pg_toast', 'information_schema')
;
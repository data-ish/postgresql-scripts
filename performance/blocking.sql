
-- https://www.postgresql.org/docs/13/view-pg-locks.html
-- https://wiki.postgresql.org/wiki/Lock_Monitoring

-- This query shows you the pids of blocking & blocked processes, plus the most recent query from that process
-- This can be slightly misleading if multiple queries are executed in the blocking_query process, this may show a later statement, not the original statement that is the root cause of the block.
select
    activity.pid,
    activity.query,
    blocking.pid as blocking_id,
    blocking.query as blocking_query
from pg_stat_activity as activity
join pg_stat_activity as blocking on blocking.pid = any(pg_blocking_pids(activity.pid))
;

-- https://www.postgresql.org/docs/13/monitoring-stats.html#PG-STAT-USER-FUNCTIONS-VIEW
-- This requires setting track_functions in postgres.conf

-- Show function call counts, total times, and average timess
select
    f.funcid,
    f.schemaname as schema_name,
    f.funcname as function_name,
    f.calls as calls,
    f.total_time as total_time,
    f.self_time as self_time,
    (f.total_time / f.calls) as average_time,
    (f.self_time / f.calls) as average_self_time
from pg_stat_user_functions as f
;
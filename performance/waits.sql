
-- https://www.postgresql.org/docs/13/monitoring-stats.html

-- https://www.postgresql.org/docs/13/monitoring-stats.html#WAIT-EVENT-TABLE
-- https://www.postgresql.org/docs/13/monitoring-stats.html#MONITORING-PG-STAT-ACTIVITY-VIEW

-- See current waits
select
    a.pid,
    a.application_name,
    a.wait_event_type,
    a.wait_event,
    a.state,
    a.query
from pg_stat_activity as a
where wait_event_type is not null
;
-- There is no historical or profile view of waits available within postgres.
-- This would require a third party tool, or some kind of scheduled snapshot/capture process.
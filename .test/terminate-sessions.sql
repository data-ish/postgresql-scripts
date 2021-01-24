select pg_terminate_backend(pid)
from pg_stat_activity
where datname = 'a22ab1c62604a'
;
-- terminate sessions so that we can drop the database

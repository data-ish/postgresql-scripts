
-- https://www.postgresql.org/docs/13/wal-intro.html
-- https://www.postgresql.org/docs/13/functions-admin.html#FUNCTIONS-ADMIN-BACKUP
-- https://www.postgresql.org/docs/13/functions-admin.html#FUNCTIONS-RECOVERY-CONTROL

-- Show the WAL file names, sizes, and last modified
select *
from pg_ls_waldir();

-- Get current write-ahead log flush location
select *
from pg_current_wal_flush_lsn();

-- Get current write-ahead log insert location
select *
from pg_current_wal_insert_lsn();

--  Get current write-ahead log write location
select *
from pg_current_wal_lsn();

-- Get the name of the current log file
select *
from pg_walfile_name(pg_current_wal_lsn());
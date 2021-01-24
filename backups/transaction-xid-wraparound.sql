
-- https://www.postgresql.org/docs/13/routine-vacuuming.html#VACUUM-FOR-WRAPAROUND

-- Show the number of transactions since the last frozen xid by object
select c.oid::regclass as table_name,
       greatest(age(c.relfrozenxid),age(t.relfrozenxid)) as age
from pg_class c
left join pg_class t on c.reltoastrelid = t.oid
where c.relkind in ('r', 'm')
;


-- Show the number of transactions since the last frozen xid by database
select
    datname,
    age(datfrozenxid) as number_transactions
from pg_database
;
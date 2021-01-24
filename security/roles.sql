
-- All Users are Roles, but not all Roles are Users
-- The login permission is assumed during create user operations, but not during create role operations

-- List users
select *
from pg_catalog.pg_user
;
-- List roles
select *
from pg_catalog.pg_roles
;


-- Get roles that are granted to users
select
    r.rolname,
    r.rolsuper,
    r.rolinherit,
    r.rolcreaterole,
    r.rolcreatedb,
    r.rolcanlogin,
    r.rolconnlimit,
    r.rolvaliduntil,
    array(
        select b.rolname
        from pg_catalog.pg_auth_members m
        join pg_catalog.pg_roles b on (m.roleid = b.oid)
        where m.member = r.oid 
    ) as memberof,
    r.rolreplication,
    r.rolbypassrls
from pg_catalog.pg_roles r
where left(r.rolname,3) != 'pg_'
and r.rolcanlogin
;
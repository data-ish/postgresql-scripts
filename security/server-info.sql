
-- https://www.postgresql.org/docs/13/functions-info.html

-- System information
-- Give information on IP Addresses, ports, user connected, uptime etc.
select 
    current_catalog as catalog_name, --sql standard, but in postgres catalog==database
    current_database()  as database_name,
    current_role as current_role,
    current_user as current_user,
    current_schema  as current_schema,
    current_schemas(true) as current_schemas,
    inet_client_addr()  as remote_address,
    inet_client_port()  as remote_port,
    inet_server_addr()  as local_address,
    inet_server_port()  as local_port,
    pg_backend_pid()    as pid,
    pg_conf_load_time() as config_load_time,
    pg_postmaster_start_time()  as server_load_time,
    version() as version
;
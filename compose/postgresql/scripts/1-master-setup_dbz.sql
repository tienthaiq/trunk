-- Create debezium user & grant replication & select permissions
create user debezium with password 'dbz_secret' replication login;
grant usage on schema public to debezium;
grant select on all tables in schema public to debezium;
alter default privileges in schema public grant select on tables to debezium;

-- Create publication slot
create publication pub__trunk_kafka_dbz for all tables;

-- Log something to WAL to allow standby to create replication slot
select pg_log_standby_snapshot();

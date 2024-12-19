# PostgreSQL master-standby setup

## Execute setup scripts

Execute CDC setup scripts in master & standby instances with super user (postgres):

1. Setup on master

```sh
psql -h 127.0.0.1 -p 5432 -U postgres -W -d dvdrental -f scripts/1-master-setup_dbz.sql
```

2. Setup on standby

```sh
# Note the port of standby instance
psql -h 127.0.0.1 -p 5433 -U postgres -W -d dvdrental -f scripts/2-replica-create_slot.sql
```

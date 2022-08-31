# Get names of PostgreSql databases

The PostgreSql DBMS has an important database named `postgres`. When a user logs in the system and connect to the `postgres` database can query the tables in this database to get information about the users and databases created.

## Problem

Suppose we want to list all the databases created in the PostgreSql.


## Solution

First, we check the name of the current database using the following command:

```SQL
SELECT *
  FROM information_schema.information_schema_catalog_name;
```

|catalog_name|
|:-----------:|
|postgres|

Next list all the `pg_catalog` tables using the following command:

```SQL
SELECT table_name
  FROM information_schema.tables;
```

```console
table_name
---------------------------------------
pg_statistic
pg_foreign_table
pg_authid
pg_shadow
pg_roles
pg_settings
pg_file_settings
pg_hba_file_rules
pg_config
pg_user_mapping
pg_replication_origin_status
...
pg_database <-----|
```

The `pg_database` table contains information about the names of the databases created.

```console
postgres=# \d pg_database
               Table "pg_catalog.pg_database"
    Column     |   Type    | Collation | Nullable | Default
---------------+-----------+-----------+----------+---------
 datname       | name      |           | not null |
 datdba        | oid       |           | not null |
 encoding      | integer   |           | not null |
 datcollate    | name      |           | not null |
 datctype      | name      |           | not null |
 datistemplate | boolean   |           | not null |
 datallowconn  | boolean   |           | not null |
 datconnlimit  | integer   |           | not null |
 datlastsysoid | oid       |           | not null |
 datfrozenxid  | xid       |           | not null |
 datminmxid    | xid       |           | not null |
 dattablespace | oid       |           | not null |
 datacl        | aclitem[] |           |          |
Indexes:
    "pg_database_datname_index" UNIQUE, btree (datname), tablespace "pg_global"
    "pg_database_oid_index" UNIQUE, btree (oid), tablespace "pg_global"
Tablespace: "pg_global"
```

To get the name of all the databases in the DBMS run the following query:

```SQL
SELECT datname
  FROM pg_database;
```


|        datname|
|:-----------------------------------:|
| postgres|
| ludovicopinzari|
| template1|
| template0|
| parch_posey|
| uniy|
| hr|
| dvdrental|
| cookbook|

An equivalent command in the `psql` console is:

```console
postgres=#\l 
```

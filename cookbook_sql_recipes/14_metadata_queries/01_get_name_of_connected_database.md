# Get the name of the connected Database

In lesson [00_psql_setup](https://github.com/lpinzari/sql-psql-udy/blob/master/00_psql_setup/04_useful_psql_commands.md) we listed some useful commands to manage database informations in PostgreSql.

However, not always the user can use the `psql` command interface and sometimes she may have access only to a SQL interface.

Suppose we are now connected through the `psql` command interface to the database `dvdrental`.

```console
dvdrental=# \conninfo
You are connected to database "dvdrental" as user "ludovicopinzari" via socket in "/tmp" at port "5432".
```

Let's assume that we do not know the name of our database and we do not have access to the common `psql` commands.

How do we get the name of the current database?

## Solution

Use the `information_schema_catalog_name` table.

```console
information_schema
     |
     +-- information_schema_catalog_name

information_schema.information_schema_catalog_name.
```

This table contains one row and one column containing the database name.

```SQL
SELECT *
  FROM information_schema.information_schema_catalog_name;
```

|catalog_name|
|:-----------:|
|dvdrental|

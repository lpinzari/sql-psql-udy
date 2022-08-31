# Listing Tables in a Schema

You want to see a list of all the tables you’ve created in a given schema.

## Solution

```SQL
SELECT table_catalog,
       table_schema,
       table_name,
       table_type
  FROM information_schema.tables
 WHERE table_schema = 'public'
 ORDER BY table_type, table_name;
```

|table_catalog | table_schema |         table_name         | table_type|
|:------------:|:-------------:|:-------------------------:|:---------:|
|dvdrental     | public       | actor                      | BASE TABLE|
|dvdrental     | public       | address                    | BASE TABLE|
|dvdrental     | public       | category                   | BASE TABLE|
|dvdrental     | public       | city                       | BASE TABLE|
|dvdrental     | public       | country                    | BASE TABLE|
|dvdrental     | public       | customer                   | BASE TABLE|
|dvdrental     | public       | film                       | BASE TABLE|
|dvdrental     | public       | film_actor                 | BASE TABLE|
|dvdrental     | public       | film_category              | BASE TABLE|
|dvdrental     | public       | inventory                  | BASE TABLE|
|dvdrental     | public       | language                   | BASE TABLE|
|dvdrental     | public       | payment                    | BASE TABLE|
|dvdrental     | public       | rental                     | BASE TABLE|
|dvdrental     | public       | staff                      | BASE TABLE|
|dvdrental     | public       | store                      | BASE TABLE|
|dvdrental     | public       | actor_info                 | VIEW|
|dvdrental     | public       | customer_list              | VIEW|
|dvdrental     | public       | film_list                  | VIEW|
|dvdrental     | public       | nicer_but_slower_film_list | VIEW|
|dvdrental     | public       | sales_by_film_category     | VIEW|
|dvdrental     | public       | sales_by_store             | VIEW|
|dvdrental     | public       | staff_list                 | VIEW|
|dvdrental     | public       | usa_cities                 | VIEW|
|dvdrental     | public       | usa_city                   | VIEW|

There are

```SQL
SELECT table_type , COUNT(*)
  FROM information_schema.tables
 WHERE table_schema = 'public'
 GROUP BY table_type
 ORDER BY table_type
```

|table_type | count|
|:---------:|:-----:|
|BASE TABLE |    15|
|VIEW       |     9|

## Discussion

In a delightfully circular manner, databases expose information about themselves through the very mechanisms that you create for your own applications: tables and views.

```console
information_schema
     |
     +-- tables

information_schema.tables.
```

Let's give a look with the `psql` command describe `\d` at the information about the `information_schema.tables` table.

```console
dvdrental=# \d information_schema.tables
                                 View "information_schema.tables"
            Column            |               Type                | Collation | Nullable | Default
------------------------------+-----------------------------------+-----------+----------+---------
 table_catalog                | information_schema.sql_identifier |           |          |
 table_schema                 | information_schema.sql_identifier |           |          |
 table_name                   | information_schema.sql_identifier |           |          |
 table_type                   | information_schema.character_data |           |          |
 self_referencing_column_name | information_schema.sql_identifier |           |          |
 reference_generation         | information_schema.character_data |           |          |
 user_defined_type_catalog    | information_schema.sql_identifier |           |          |
 user_defined_type_schema     | information_schema.sql_identifier |           |          |
 user_defined_type_name       | information_schema.sql_identifier |           |          |
 is_insertable_into           | information_schema.yes_or_no      |           |          |
 is_typed                     | information_schema.yes_or_no      |           |          |
 commit_action                | information_schema.character_data |           |          |
```

To access the `public` tables created in the `dvdrental` database we set `table_schema = public`.

There other types of `table_schema` as illustrated below:

```SQL
SELECT DISTINCT(table_schema)
  FROM information_schema.tables
 ORDER BY table_schema;
```

|table_schema|
|:----------------:|
|information_schema|
|pg_catalog|
|public|
